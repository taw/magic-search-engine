class PatchNonTournament < Patch
  # A printing you cannot bring to a sanctioned event. Two unrelated reasons, and this
  # is where they meet:
  #
  # * the object isn't a traditional Magic card - oversized, thick, gold-bordered,
  #   Collectors' Edition. Set by PatchMtgjsonVersions as `nontraditional`.
  # * the card is one of CR 100.7's "intended for casual play" cards - Mystery Booster
  #   playtest cards, silver-bordered un-cards, acorn-stamped Unfinity cards, and the
  #   rest of the products that list is not exhaustive about.
  #
  # This is what formats consult. It is deliberately not derived from `funny`, which is
  # a card-level flag about whether a card is a joke - the two answer different questions
  # and `funny` should be free to change without moving anyone's legality.

  # Products where no printing is tournament legal.
  #
  # This is the funny set list (including Heroes of the Realm, which PatchSetTypes marks
  # by name) minus mb2. MB2 mixes 126 playtest cards with 264 ordinary reprints, and
  # Goblin Gang Leader, Mardu Outrider and Velukan Dragon have no other paper printing -
  # marking the whole set would ban them. Their playtest slots are caught by promo type
  # instead, which is the per-printing fact WotC actually publishes.
  SetsWithNoTournamentPrintings = %W[mb2].to_set.freeze

  # Printings nothing in the data marks - no silver border, no stamp, no promo type,
  # ordinary-looking set - so they have to be named:
  #
  # * black-bordered o90p / olep promo reprints of un-cards, and the sld Blacker Lotus
  # * Gleemox, an MTGO promo whose own rules text is "This card is banned."
  NamedNonTournamentCards = [
    "Blacker Lotus",
    "Gleemox",
    "Incoming!",
    "Infernal Spawn of Evil",
    "Mirror Mirror",
    "Squirrel Farm",
  ].to_set.freeze

  def call
    funny_sets = @sets.select{|set| set["funny"]}.map{|set| set["code"].downcase}.to_set - SetsWithNoTournamentPrintings

    each_printing do |printing|
      nontournament = printing["nontraditional"]
      nontournament ||= printing["border"] == "silver"
      nontournament ||= printing["stamp"] == "acorn" || printing["stamp"] == "heart"
      nontournament ||= printing["promo_types"]&.include?("playtest")
      nontournament ||= funny_sets.include?(printing["set_code"])
      nontournament ||= UncardPromos.include?(printing["name"])

      printing["nontournament"] = true if nontournament
    end
  end
end

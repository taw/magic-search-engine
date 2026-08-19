class PatchFunny < Patch
  # Promo sets which mix a few funny cards in with ordinary reprints.
  # They are not funny sets - st:funny should not return "Judge Gift Cards 2017" -
  # but a card printed only here and nowhere else is still funny.
  #
  # This is only for sets where the funny cards are the exception. Sets whose
  # unique cards are mostly funny (mb2, mbc, pcel, past, un-sets) stay funny sets.
  SetsWithSomeFunnyCards = %W[j17 o90p olep p30m pal04 pf24 pf25 pf26]

  def call
    # additional funny cards that don't follow the rules
    funny_cards = [
      "Blacker Lotus", # SLD printing with triangle stamp for some reason
    ].to_set

    errata_sets = @sets.select{|set| set["types"].include?("errata")}.map{|set| set["code"].downcase}
    funny_sets = @sets.select{|set| set["funny"]}.map{|set| set["code"].downcase} + SetsWithSomeFunnyCards

    each_card do |name, printings|
      funny = printings.any?{|card| card["stamp"] == "acorn" or card["stamp"] == "heart" }
      # For cards predating stamp system
      funny ||= printings.all?{|card|
        funny_sets.include?(card["set_code"]) or
        errata_sets.include?(card["set_code"])
      }
      funny ||= funny_cards.include?(name)

      if funny
        printings.each do |printing|
          printing["funny"] = true
        end
      end
    end
  end
end

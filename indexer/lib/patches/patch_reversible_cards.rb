# Reversible cards are totally ridiculous, and mtgjson shouldn't be pretending
# it's a single damn card. With SLD it was at least 2 faces we could split but
# TDM has ridiculous 4-faced cards. These are two separate cards as far as game
# rules are concerned, so we split them back apart and give each face its own
# collector number.
#
# This has to run before PatchMultipartCardNumbers and PatchVerifyCollectorNumbers,
# as the numbers it assigns are what makes them unique within their set.

class PatchReversibleCards < Patch
  def call
    each_printing do |card|
      next unless card["layout"] == "reversible_card"
      case card["setCode"]
      when "SNC", "PSNC"
        # This looks like garbage data in mtgjson, these aren't reversible at all
        unreverse(card)
      when "SLD", "REX", "ECL"
        # These are at least easily fixable
        unreverse(card)
        assign_number(card)
      when "TDM"
        patch_tdm(card)
      else
        warn "Can't handle reversible card #{card["name"]} #{card["names"]} #{card["setCode"]} #{card["number"]}"
        unreverse(card)
      end
    end
  end

  private

  def unreverse(card)
    card["layout"] = "normal"
    card.delete "names"
  end

  # TDM omen cards are printed as adventures on one side and a creature on the
  # other, and mtgjson glues all four faces into a single reversible card.
  def patch_tdm(card)
    case card["name"]
    when "Clarion Conqueror", "Magmatic Hellkite", "Ugin, Eye of the Storms"
      unreverse(card)
      assign_number(card)
    when "Marang River Regent", "Scavenger Regent", "Bloomvine Regent"
      card["layout"] = "adventure"
      card["names"] = tdm_omens.fetch(card["name"])
      assign_number(card)
    when "Coil and Catch", "Exude Toxin", "Claim Territory"
      card["layout"] = "adventure"
      card["names"] = tdm_omens.fetch(card["name"])
      assign_number(card)
      card.delete "power"
      card.delete "toughness"
      # mtgjson has a typo in the remainder text
      card["text"] = tdm_omen_text.fetch(card["name"])
      card["keywords"] = tdm_omen_keywords.fetch(card["name"])
    else
      warn "Can't handle reversible card #{card["name"]} #{card["names"]} #{card["setCode"]} #{card["number"]}"
      unreverse(card)
    end
  end

  def tdm_omens
    @tdm_omens ||= [
      ["Marang River Regent", "Coil and Catch"],
      ["Scavenger Regent", "Exude Toxin"],
      ["Bloomvine Regent", "Claim Territory"],
    ].flat_map{|names| names.map{|name| [name, names]} }.to_h
  end

  def tdm_omen_text
    {
      "Coil and Catch" => "Draw three cards, then discard a card. (Then shuffle this card into its owner's library.)",
      "Exude Toxin" => "Each non-Dragon creature gets -X/-X until end of turn. (Then shuffle this card into its owner's library.)",
      "Claim Territory" => "Search your library for up to two basic Forest cards, reveal them, put one onto the battlefield tapped and the other into your hand, then shuffle. (Also shuffle this card.)",
    }
  end

  # The creature side's keywords, which mtgjson puts on both faces
  def tdm_omen_keywords
    {
      "Coil and Catch" => ["flying"],
      "Exude Toxin" => ["flying", "ward"],
      "Claim Territory" => ["flying"],
    }
  end

  # Each face gets the original number plus a letter, and a promo type saying
  # which physical side it is
  def assign_number(card)
    @seen ||= {}
    key = [card["setCode"], card["number"]]
    counter = "a"
    counter.succ! while @seen[[*key, counter]]
    @seen[[*key, counter]] = card["name"]

    card["promo_types"] ||= []
    case counter
    when "a"
      card["promo_types"] << "reversiblefront"
    when "b"
      # A hack for 4 faced cards
      if @seen[[*key, counter]] == @seen[[*key, "a"]]
        card["promo_types"] << "reversibleback"
      else
        card["promo_types"] << "reversiblefront"
      end
    else
      warn "More than two parts of same reversible card #{key.join(" ")}"
    end
    card["number"] = "#{card["number"]}#{counter}"
  end
end

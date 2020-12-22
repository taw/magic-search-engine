# Translate mtgjson foiling into system we use
# This used to actually calculate foiling, but there's no point since mtgjson does it for us

class PatchFoiling < Patch
  def call
    each_printing do |card|
      case [card["hasNonFoil"], card["hasFoil"]]
      when [true, true]
        card["foiling"] = "both"
      when [true, false]
        card["foiling"] = "nonfoil"
      when [false, true]
        card["foiling"] = "foilonly"
      else
        warn "Bad foiling information for #{card["name"]} in #{card["set_code"]}"
      end
      card.delete "hasFoil"
      card.delete "hasNonFoil"
    end

    # And now fix foiling errors in mtgjson
    each_printing do |card|
      if card["set_code"] == "usg" or card["set_code"] == "por"
        fix_to card, "nonfoil"
        card["foiling"] = "nonfoil"
      end

      if card["set_code"] == "inv"
        fix_to card, "both"
        card["foiling"] = "both"
      end
    end
  end

  def fix_to(card, fixed)
    return if card["foiling"] == fixed
    warn "Fixing foiling of #{card["name"]} [#{card["set_code"]}/#{card["number"]}] to #{fixed}"
  end
end

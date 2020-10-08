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
  end
end

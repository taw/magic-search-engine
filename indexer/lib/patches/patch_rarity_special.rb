# mtgjson v4 dropped "special" rarity, but it's useful for a few cards
# (and now v5 has a lot of rarities back)
class PatchRaritySpecial < Patch
  def call
    each_printing do |card|
      if card["set_code"] == "unh" and card["name"] == "Super Secret Tech"
        card["rarity"] = "special"
      end
    end

    each_printing do |card|
      case card["rarity"]
      when "common", "uncommon", "basic", "rare", "mythic", "special"
        # OK
      when "bonus"
        # VMA power nine
        card["rarity"] = "special"
      else
        raise "Unknown rarity: #{card["rarity"]}"
      end
    end
  end
end

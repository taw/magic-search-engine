# mtgjson v4 dropped "special" rarity, but it's useful for a few cards
# (and now v5 has a lot of rarities back)
class PatchRaritySpecial < Patch
  def call
    vma_special = [
      "Ancestral Recall",
      "Black Lotus",
      "Mox Emerald",
      "Mox Jet",
      "Mox Pearl",
      "Mox Ruby",
      "Mox Sapphire",
      "Time Walk",
      "Timetwister",
    ]

    each_printing do |card|
      case card["set_code"]
      when "vma"
        next unless vma_special.include?(card["name"])
      when "unh"
        next unless card["name"] == "Super Secret Tech"
      else
        next
      end
      card["rarity"] = "special"
    end

    each_printing do |card|
      case card["rarity"]
      when "common", "uncommon", "basic", "rare", "mythic", "special"
        # OK
      when "bonus"
        # wtf now mtgjson...
        card["rarity"] = "special"
      else
        warn "Unknown rarity: #{card["rarity"]}"
        binding.pry
      end
    end
  end
end

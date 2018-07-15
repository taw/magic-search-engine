class PatchClashPacksRarity < Patch
  def call
    each_printing do |card|
      next unless %W[cp1 cp2 cp3].include?(card["set_code"])
      # Already fixed?
      raise unless card["rarity"] == "special"
      card["rarity"] = case card["name"]
      when "Font of Fertility"
        "common"
      when "Sandsteppe Citadel", "Seeker of the Way", "Valorous Stance"
        "uncommon"
      else
        "rare"
      end
    end
  end
end

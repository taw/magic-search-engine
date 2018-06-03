class PatchNormalizeRarity < Patch
  def call
    patch_card do |card|
      rarity = card["rarity"].downcase
      card["rarity"] = case rarity
      when "mythic rare"
        "mythic"
      when "basic land"
        "basic"
      else
        rarity
      end
    end
  end
end

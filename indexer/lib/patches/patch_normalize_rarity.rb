class PatchNormalizeRarity < Patch
  def call
    each_printing do |card|
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

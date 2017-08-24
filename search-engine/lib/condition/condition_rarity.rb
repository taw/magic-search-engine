class ConditionRarity < ConditionSimple
  def initialize(rarity)
    @rarity = rarity.downcase
    @rarity_code = %W[basic common uncommon rare mythic special].index(@rarity) or raise "Unknown rarity #{@rarity}"
  end

  def match?(card)
    card.rarity_code == @rarity_code
  end

  def to_s
    "r:#{@rarity}"
  end
end

class ConditionRarity < Condition
  def initialize(rarity)
    @rarity = rarity.downcase
  end

  def match?(card)
    card.rarity == @rarity
  end

  def to_s
    "r:#{@rarity}"
  end
end

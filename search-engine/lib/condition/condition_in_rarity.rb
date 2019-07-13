class ConditionInRarity < ConditionIn
  def initialize(rarity)
    @rarity = rarity
  end

  def match?(card)
    card.rarity == @rarity
  end

  def to_s
    "in:#{@rarity}"
  end
end

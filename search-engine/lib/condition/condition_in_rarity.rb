class ConditionInRarity < ConditionIn
  def initialize(rarity)
    @rarity = rarity
    @rarity = "special" if @rarity == "bonus"
  end

  def match?(card)
    card.rarity == @rarity
  end

  def to_s
    "in:#{@rarity}"
  end
end

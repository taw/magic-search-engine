class ConditionInDreamcast < ConditionIn
  def match?(card)
    card.dreamcast?
  end

  def to_s
    "in:dreamcast"
  end

  def explain(negated: false)
    negated ? "the card has no printing available on the Sega Dreamcast" : "the card has a printing available on the Sega Dreamcast"
  end
end

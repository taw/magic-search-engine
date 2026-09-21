class ConditionInDreamcast < ConditionIn
  def match?(card)
    card.dreamcast?
  end

  def to_s
    "in:dreamcast"
  end

  def explain
    "the card has a printing available on the Sega Dreamcast"
  end
end

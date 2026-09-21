class ConditionIsDreamcast < ConditionSimple
  def match?(card)
    card.dreamcast?
  end

  def to_s
    "game:dreamcast"
  end

  def explain
    "the card is available in the Sega Dreamcast game"
  end
end

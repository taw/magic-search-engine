class ConditionIsDreamcast < ConditionSimple
  def match?(card)
    card.dreamcast?
  end

  def to_s
    "game:dreamcast"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}available in the Sega Dreamcast game"
  end
end

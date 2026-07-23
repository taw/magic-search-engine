class ConditionIsDreamcast < ConditionSimple
  def match?(card)
    card.dreamcast?
  end

  def to_s
    "game:dreamcast"
  end
end

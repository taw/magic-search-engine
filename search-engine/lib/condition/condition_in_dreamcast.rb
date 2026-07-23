class ConditionInDreamcast < ConditionIn
  def match?(card)
    card.dreamcast?
  end

  def to_s
    "in:dreamcast"
  end
end

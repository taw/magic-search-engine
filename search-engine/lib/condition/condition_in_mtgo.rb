class ConditionInMtgo < ConditionIn
  def match?(card)
    card.mtgo?
  end

  def to_s
    "in:mtgo"
  end
end

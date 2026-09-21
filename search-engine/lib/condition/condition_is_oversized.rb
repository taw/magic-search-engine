class ConditionIsOversized < ConditionSimple
  def match?(card)
    card.oversized
  end

  def to_s
    "is:oversized"
  end

  def explain
    "the card is oversized"
  end
end

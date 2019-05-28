class ConditionIsOversized < ConditionSimple
  def match?(card)
    card.oversized
  end

  def to_s
    "is:oversized"
  end
end

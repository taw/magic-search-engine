class ConditionIsPrimary < ConditionSimple
  def match?(card)
    !card.secondary
  end

  def to_s
    "is:primary"
  end
end

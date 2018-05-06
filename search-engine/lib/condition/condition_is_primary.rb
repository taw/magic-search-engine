class ConditionIsPrimary < ConditionSimple
  def match?(card)
    card.primary?
  end

  def to_s
    "is:primary"
  end
end

class ConditionIsSecondary < ConditionSimple
  def match?(card)
    card.secondary?
  end

  def to_s
    "is:secondary"
  end
end

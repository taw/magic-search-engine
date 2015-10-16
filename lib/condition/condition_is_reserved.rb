class ConditionIsReserved < Condition
  def match?(card)
    card.reserved
  end

  def to_s
    "is:reserved"
  end
end

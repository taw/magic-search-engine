class ConditionIsReserved < ConditionSimple
  def match?(card)
    card.reserved
  end

  def to_s
    "is:reserved"
  end

  def explain
    "the card is on the Reserved List"
  end
end

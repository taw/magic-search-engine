class ConditionIsReserved < ConditionSimple
  def match?(card)
    card.reserved
  end

  def to_s
    "is:reserved"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}on the Reserved List"
  end
end

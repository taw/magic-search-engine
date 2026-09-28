class ConditionIsTimeshifted < ConditionSimple
  def match?(card)
    card.timeshifted
  end

  def to_s
    "is:timeshifted"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}timeshifted"
  end
end

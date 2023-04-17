class ConditionIsTimeshifted < ConditionSimple
  def match?(card)
    card.timeshifted
  end

  def to_s
    "is:timeshifted"
  end
end

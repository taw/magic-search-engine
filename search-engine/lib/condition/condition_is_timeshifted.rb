class ConditionIsTimeshifted < ConditionSimple
  def match?(card)
    card.set_code.downcase == "tsb"
  end

  def to_s
    "is:timeshifted"
  end
end

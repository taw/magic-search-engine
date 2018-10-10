class ConditionIsTimeshifted < ConditionSimple
  def match?(card)
    card.timeshifted and card.set_code.downcase == "plc"
  end

  def to_s
    "is:timeshifted"
  end
end

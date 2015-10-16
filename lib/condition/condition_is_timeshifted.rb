class ConditionIsTimeshifted < Condition
  def match?(card)
    card.timeshifted and card.set_code.downcase == "pc"
  end

  def to_s
    "is:timeshifted"
  end
end

class ConditionIsNonfoilonly < ConditionSimple
  def match?(card)
    card.nonfoilonly?
  end

  def to_s
    "is:nonfoilonly"
  end
end

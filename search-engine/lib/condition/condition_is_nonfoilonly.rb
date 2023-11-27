class ConditionIsNonfoilonly < ConditionSimple
  def match?(card)
    card.foiling == :nonfoil
  end

  def to_s
    "is:nonfoilonly"
  end
end

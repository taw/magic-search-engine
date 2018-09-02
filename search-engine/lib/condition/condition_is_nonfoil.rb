class ConditionIsNonfoil < ConditionSimple
  def match?(card)
    ["nonfoil", "both"].include?(card.foiling)
  end

  def to_s
    "is:nonfoil"
  end
end

class ConditionInNonfoil < ConditionIn
  def match?(card)
    ["nonfoil", "both"].include?(card.foiling)
  end

  def to_s
    "in:nonfoil"
  end
end

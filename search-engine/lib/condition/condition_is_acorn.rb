class ConditionIsAcorn < ConditionSimple
  def match?(card)
    card.acorn
  end

  def to_s
    "is:acorn"
  end
end

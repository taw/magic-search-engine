class ConditionIsCard < ConditionSimple
  def match?(card)
    !card.token
  end

  def to_s
    "is:card"
  end
end

class ConditionIsToken < ConditionSimple
  def match?(card)
    card.token
  end

  def to_s
    "is:token"
  end
end

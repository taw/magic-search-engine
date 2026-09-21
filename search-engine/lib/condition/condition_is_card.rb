class ConditionIsCard < ConditionSimple
  def match?(card)
    !card.token
  end

  def to_s
    "is:card"
  end

  def explain
    "the card is not a token"
  end
end

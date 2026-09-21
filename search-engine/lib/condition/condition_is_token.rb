class ConditionIsToken < ConditionSimple
  def match?(card)
    card.token
  end

  def to_s
    "is:token"
  end

  def explain
    "the card is a token"
  end
end

class ConditionIsToken < ConditionSimple
  def match?(card)
    card.token
  end

  def to_s
    "is:token"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a token"
  end
end

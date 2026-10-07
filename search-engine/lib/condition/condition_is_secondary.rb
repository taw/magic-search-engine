class ConditionIsSecondary < ConditionSimple
  def match?(card)
    card.secondary?
  end

  def to_s
    "is:secondary"
  end

  def explain(negated: false)
    negated ? "the card is directly playable" : "the card is not directly playable"
  end
end

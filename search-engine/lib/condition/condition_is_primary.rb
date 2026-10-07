class ConditionIsPrimary < ConditionSimple
  def match?(card)
    card.primary?
  end

  def to_s
    "is:primary"
  end

  def explain(negated: false)
    negated ? "the card is not directly playable" : "the card is directly playable"
  end
end

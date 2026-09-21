class ConditionInXmage < ConditionIn
  def match?(card)
    card.xmage?
  end

  def to_s
    "in:xmage"
  end

  def explain(negated: false)
    negated ? "the card has no printing available on Xmage" : "the card has a printing available on Xmage"
  end
end

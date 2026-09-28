class ConditionInMtgo < ConditionIn
  def match?(card)
    card.mtgo?
  end

  def to_s
    "in:mtgo"
  end

  def explain(negated: false)
    negated ? "the card has no printing available on Magic Online" : "the card has a printing available on Magic Online"
  end
end

class ConditionInShandalar < ConditionIn
  def match?(card)
    card.shandalar?
  end

  def to_s
    "in:shandalar"
  end

  def explain(negated: false)
    negated ? "the card has no printing available on Shandalar" : "the card has a printing available on Shandalar"
  end
end

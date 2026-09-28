class ConditionInArena < ConditionIn
  def match?(card)
    card.arena?
  end

  def to_s
    "in:arena"
  end

  def explain(negated: false)
    negated ? "the card has no printing available on Arena" : "the card has a printing available on Arena"
  end
end

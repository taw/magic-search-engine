class ConditionInPaper < ConditionIn
  def match?(card)
    card.paper?
  end

  def to_s
    "in:paper"
  end

  def explain(negated: false)
    negated ? "the card has no printing available as a tournament-legal paper card" : "the card has a printing available as a tournament-legal paper card"
  end
end

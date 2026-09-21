class ConditionInPaper < ConditionIn
  def match?(card)
    card.paper?
  end

  def to_s
    "in:paper"
  end

  def explain
    "the card has a printing available as a tournament-legal paper card"
  end
end

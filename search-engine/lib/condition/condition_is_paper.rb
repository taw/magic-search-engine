class ConditionIsPaper < ConditionSimple
  def match?(card)
    card.paper?
  end

  def to_s
    "game:paper"
  end

  def explain
    "the card is available as a paper card"
  end
end

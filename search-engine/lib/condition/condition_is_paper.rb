class ConditionIsPaper < ConditionSimple
  def match?(card)
    card.paper?
  end

  def to_s
    "game:paper"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}available as a paper card"
  end
end

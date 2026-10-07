class ConditionIsFunny < ConditionSimple
  def match?(card)
    card.funny
  end

  def to_s
    "is:funny"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}funny"
  end
end

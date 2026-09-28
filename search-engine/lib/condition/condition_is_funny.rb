class ConditionIsFunny < ConditionSimple
  def match?(card)
    card.funny
  end

  def to_s
    "is:funny"
  end

  def explain(negated: false)
    negated ? "the card is not from a funny set, and is not an acorn-marked card from a mixed set" : "the card is from a funny set, or is an acorn-marked card from a mixed set"
  end
end

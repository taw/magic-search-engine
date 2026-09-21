class ConditionIsFunny < ConditionSimple
  def match?(card)
    card.funny
  end

  def to_s
    "is:funny"
  end

  def explain
    "the card is from a funny set, or is an acorn-marked card from a mixed set"
  end
end

class ConditionIsFunny < ConditionSimple
  def match?(card)
    card.funny
  end

  def to_s
    "is:funny"
  end
end

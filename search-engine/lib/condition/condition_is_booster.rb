class ConditionIsBooster < ConditionSimple
  def match?(card)
    card.in_boosters?
  end

  def to_s
    "is:booster"
  end

  def explain
    "the card appears in randomized boosters"
  end
end

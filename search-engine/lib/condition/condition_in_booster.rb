class ConditionInBooster < ConditionIn
  def match?(card)
    card.in_boosters?
  end

  def to_s
    "in:booster"
  end

  def explain
    "the card has a version in boosters"
  end
end

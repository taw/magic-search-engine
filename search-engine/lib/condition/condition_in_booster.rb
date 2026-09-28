class ConditionInBooster < ConditionIn
  def match?(card)
    card.in_boosters?
  end

  def to_s
    "in:booster"
  end

  def explain(negated: false)
    negated ? "the card has no version in boosters" : "the card has a version in boosters"
  end
end

class ConditionIsBooster < ConditionSimple
  def match?(card)
    card.in_boosters?
  end

  def to_s
    "is:booster"
  end

  def explain(negated: false)
    negated ? "the card does not appear in randomized boosters" : "the card appears in randomized boosters"
  end
end

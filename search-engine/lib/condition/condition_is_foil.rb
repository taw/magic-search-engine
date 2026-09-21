class ConditionIsFoil < ConditionSimple
  def match?(card)
    card.any_foil?
  end

  def to_s
    "is:foil"
  end

  def explain(negated: false)
    "the card #{negated ? "has no" : "has a"} foil version"
  end
end

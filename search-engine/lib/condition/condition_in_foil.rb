class ConditionInFoil < ConditionIn
  def match?(card)
    card.any_foil?
  end

  def to_s
    "in:foil"
  end

  def explain(negated: false)
    "the card has #{negated ? "no" : "a"} foil version"
  end
end

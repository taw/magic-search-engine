class ConditionInFoil < ConditionIn
  def match?(card)
    card.any_foil?
  end

  def to_s
    "in:foil"
  end

  def explain
    "the card has a foil version"
  end
end

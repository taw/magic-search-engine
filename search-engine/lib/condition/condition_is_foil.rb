class ConditionIsFoil < ConditionSimple
  def match?(card)
    card.any_foil?
  end

  def to_s
    "is:foil"
  end

  def explain
    "the card has a foil version"
  end
end

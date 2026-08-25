class ConditionIsFoil < ConditionSimple
  def match?(card)
    card.any_foil?
  end

  def to_s
    "is:foil"
  end
end

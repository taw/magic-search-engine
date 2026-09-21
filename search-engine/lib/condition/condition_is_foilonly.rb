class ConditionIsFoilonly < ConditionSimple
  def match?(card)
    card.foilonly?
  end

  def to_s
    "is:foilonly"
  end

  def explain
    "the card exists only in foil"
  end
end

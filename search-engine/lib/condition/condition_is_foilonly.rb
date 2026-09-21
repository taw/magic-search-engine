class ConditionIsFoilonly < ConditionSimple
  def match?(card)
    card.foilonly?
  end

  def to_s
    "is:foilonly"
  end

  def explain(negated: false)
    negated ? "the card is not foil-only" : "the card exists only in foil"
  end
end

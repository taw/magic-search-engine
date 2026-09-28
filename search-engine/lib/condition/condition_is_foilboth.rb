class ConditionIsFoilboth < ConditionSimple
  def match?(card)
    card.foilboth?
  end

  def to_s
    "is:foilboth"
  end

  def explain(negated: false)
    negated ? "the card does not have both foil and nonfoil versions" : "the card has both foil and nonfoil versions"
  end
end

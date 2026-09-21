class ConditionIsFoilboth < ConditionSimple
  def match?(card)
    card.foilboth?
  end

  def to_s
    "is:foilboth"
  end

  def explain
    "the card has both foil and nonfoil versions"
  end
end

class ConditionIsFoilboth < ConditionSimple
  def match?(card)
    card.foilboth?
  end

  def to_s
    "is:foilboth"
  end
end

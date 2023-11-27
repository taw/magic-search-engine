class ConditionIsFoilboth < ConditionSimple
  def match?(card)
    card.foiling == :both
  end

  def to_s
    "is:foilboth"
  end
end

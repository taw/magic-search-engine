class ConditionIsFoilonly < ConditionSimple
  def match?(card)
    card.foilonly?
  end

  def to_s
    "is:foilonly"
  end
end

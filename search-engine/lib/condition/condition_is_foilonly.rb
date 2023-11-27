class ConditionIsFoilonly < ConditionSimple
  def match?(card)
    card.foiling == :foilonly
  end

  def to_s
    "is:foilonly"
  end
end

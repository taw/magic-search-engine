class ConditionInFoil < ConditionIn
  def match?(card)
    ["foilonly", "both"].include?(card.foiling)
  end

  def to_s
    "in:foil"
  end
end

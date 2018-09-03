class ConditionIsfoil < ConditionSimple
  def match?(card)
    ["foilonly", "both"].include?(card.foiling)
  end

  def to_s
    "is:foil"
  end
end

class ConditionIsSpell < Condition
  def match?(card)
    card.types.all?{|t| t != "land"}
  end

  def to_s
    "is:spell"
  end
end

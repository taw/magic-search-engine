class ConditionIsSpell < ConditionSimple
  def match?(card)
    card.types.all?{|t| t != "land"}
  end

  def to_s
    "is:spell"
  end

  def explain(negated: false)
    negated ? "the card is a land" : "the card is a spell, not a land"
  end
end

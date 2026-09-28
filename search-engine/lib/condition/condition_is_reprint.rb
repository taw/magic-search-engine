class ConditionIsReprint < ConditionSimple
  def match?(card)
    card.age > 0
  end

  def to_s
    "is:reprint"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a reprint"
  end
end

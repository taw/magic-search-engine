class ConditionHasFlavor < ConditionSimple
  def match?(card)
    !card.flavor.empty?
  end

  def to_s
    "has:flavor"
  end

  def explain(negated: false)
    negated ? "the card has no flavor text" : "the card has flavor text"
  end
end

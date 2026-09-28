class ConditionIsOversized < ConditionSimple
  def match?(card)
    card.oversized
  end

  def to_s
    "is:oversized"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}oversized"
  end
end

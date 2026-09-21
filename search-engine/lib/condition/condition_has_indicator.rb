class ConditionHasIndicator < ConditionSimple
  def match?(card)
    !!card.color_indicator
  end

  def to_s
    "has:indicator"
  end

  def explain(negated: false)
    negated ? "the card has no color indicator" : "the card has a color indicator"
  end
end

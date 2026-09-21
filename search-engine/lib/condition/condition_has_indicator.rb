class ConditionHasIndicator < ConditionSimple
  def match?(card)
    !!card.color_indicator
  end

  def to_s
    "has:indicator"
  end

  def explain
    "the card has a color indicator"
  end
end

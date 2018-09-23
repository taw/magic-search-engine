class ConditionColorIndicatorAny < ConditionSimple
  # Matches cards with a color indicator
  def match?(card)
    card.color_indicator
  end

  def to_s
    "in:*"
  end
end

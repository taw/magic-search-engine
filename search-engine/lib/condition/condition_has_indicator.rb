class ConditionHasIndicator < ConditionSimple
  def match?(card)
    !!card.color_indicator
  end

  def to_s
    "has:indicator"
  end
end

class ConditionHasWatermark < ConditionSimple
  def match?(card)
    !!card.watermark
  end

  def to_s
    "has:watermark"
  end

  def explain
    "the card has a watermark"
  end
end

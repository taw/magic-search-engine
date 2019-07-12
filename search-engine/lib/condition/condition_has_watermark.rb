class ConditionHasWatermark < ConditionSimple
  def match?(card)
    !!card.watermark
  end

  def to_s
    "has:watermark"
  end
end

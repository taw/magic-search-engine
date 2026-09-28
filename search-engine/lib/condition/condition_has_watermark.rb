class ConditionHasWatermark < ConditionSimple
  def match?(card)
    !!card.watermark
  end

  def to_s
    "has:watermark"
  end

  def explain(negated: false)
    negated ? "the card has no watermark" : "the card has a watermark"
  end
end

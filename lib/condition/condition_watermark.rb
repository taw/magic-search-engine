class ConditionWatermark < ConditionSimple
  def initialize(watermark)
    @watermark = watermark.downcase
  end

  def match?(card)
    card.watermark == @watermark
  end

  def to_s
    "w:#{@watermark}"
  end
end

class ConditionWatermark < Condition
  def initialize(watermark)
    @watermark = watermark.downcase
  end

  def match?(card)
    card.watermark == @watermark
  end

  def to_s
    "watermark:#{@watermark}"
  end
end

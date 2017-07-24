class ConditionWatermark < ConditionSimple
  def initialize(watermark)
    @watermark = watermark.downcase
  end

  def match?(card)
    if @watermark == "*"
      card.watermark != nil
    else
      card.watermark == @watermark
    end
  end

  def to_s
    "w:#{@watermark}"
  end
end

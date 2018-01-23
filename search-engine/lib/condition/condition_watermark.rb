class ConditionWatermark < ConditionSimple
  def initialize(watermark)
    @watermark = watermark.downcase
  end

  def match?(card)
    return false unless card.watermark
    return true if @watermark == "*"
    card.watermark.downcase.gsub(/[^a-z]+/i, "").include?(@watermark.gsub(/[^a-z]+/i, ""))
  end

  def to_s
    "w:#{maybe_quote(@watermark)}"
  end
end

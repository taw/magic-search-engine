class ConditionWatermark < ConditionSimple
  def initialize(watermark)
    @watermark = watermark.downcase
    @any = (@watermark == "*")
    @watermark_letters = @watermark.gsub(/[^a-z]+/i, "")
  end

  def match?(card)
    return false unless card.watermark
    return true if @any
    card.watermark.downcase.gsub(/[^a-z]+/i, "").include?(@watermark_letters)
  end

  def to_s
    "w:#{maybe_quote(@watermark)}"
  end
end

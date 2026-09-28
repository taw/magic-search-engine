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

  def explain(negated: false)
    if @any
      negated ? "the card has no watermark" : "the card has a watermark"
    else
      verb = negated ? "doesn't include" : "includes"
      %[the watermark #{verb} "#{@watermark}"]
    end
  end
end

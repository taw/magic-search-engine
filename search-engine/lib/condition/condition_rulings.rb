class ConditionRulings < ConditionSimple
  def initialize(ruling)
    @ruling = ruling.downcase
    ruling_normalized = @ruling.normalize_accents
    @ruling_rx = Regexp.new("\\b(?:" + Regexp.escape(ruling_normalized) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    return false unless card.rulings
    return true if @ruling == "*"
    card.rulings.any?{|r| r["text"] =~ @ruling_rx }
  end

  def to_s
    "rulings:#{maybe_quote(@ruling)}"
  end
end

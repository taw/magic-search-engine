class ConditionSubset < ConditionSimple
  def initialize(subset)
    @subset = subset.downcase
    subset_normalized = @subset.normalize_accents
    # no \b checks as some names include punctuation
    @subset_rx = Regexp.new("(?:" + Regexp.escape(subset_normalized) + ")", Regexp::IGNORECASE)
  end

  def match?(card)
    return false unless card.subsets
    card.subsets.any?{|subset| subset =~ @subset_rx}
  end

  def to_s
    "subset:#{maybe_quote(@subset)}"
  end
end

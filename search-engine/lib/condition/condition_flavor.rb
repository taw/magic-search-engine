class ConditionFlavor < ConditionSimple
  def initialize(flavor)
    @flavor = flavor
    flavor_normalized = @flavor.normalize_accents
    @flavor_rx = Regexp.new("\\b(?:" + Regexp.escape(flavor_normalized) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    card.flavor_normalized =~ @flavor_rx
  end

  def to_s
    "ft:#{maybe_quote(@flavor)}"
  end
end

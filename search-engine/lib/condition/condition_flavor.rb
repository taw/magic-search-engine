class ConditionFlavor < ConditionSimple
  def initialize(flavor)
    @flavor = flavor
    @flavor_rx = Regexp.new("\\b(?:" + Regexp.escape(flavor.downcase) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    card.flavor =~ @flavor_rx
  end

  def to_s
    "ft:#{maybe_quote(@flavor)}"
  end
end

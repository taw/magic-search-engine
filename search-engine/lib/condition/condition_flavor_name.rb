class ConditionFlavorName < ConditionSimple
  def initialize(flavor_name)
    @flavor_name = flavor_name
    flavor_name_normalized = @flavor_name.normalize_accents
    @flavor_name_rx = Regexp.new("\\b(?:" + Regexp.escape(flavor_name_normalized) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    return false unless card.flavor_name
    return true if @flavor_name == "*"
    card.flavor_name =~ @flavor_name_rx
  end

  def to_s
    "fn:#{maybe_quote(@flavor_name)}"
  end
end

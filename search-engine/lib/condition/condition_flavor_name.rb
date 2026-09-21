class ConditionFlavorName < ConditionSimple
  def initialize(flavor_name)
    @flavor_name = flavor_name
    @any = (flavor_name == "*")
    flavor_name_normalized = @flavor_name.normalize_accents
    @flavor_name_rx = Regexp.new("\\b(?:" + Regexp.escape(flavor_name_normalized) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    return false unless card.flavor_name
    return true if @any
    card.flavor_name.normalize_accents =~ @flavor_name_rx
  end

  def to_s
    "fn:#{maybe_quote(@flavor_name)}"
  end

  def explain(negated: false)
    if @any
      negated ? "the card has no flavor name" : "the card has a flavor name"
    else
      verb = negated ? "doesn't include" : "includes"
      %[the flavor name #{verb} "#{@flavor_name}"]
    end
  end
end

class ConditionLore < ConditionSimple
  def initialize(query)
    @query = query.downcase
    @conds = [
      ConditionWord.new(query),
      ConditionFlavor.new(query),
      ConditionTypes.new(query),
    ]
  end

  def match?(card)
    @conds.any?{|cond|
      cond.match?(card)
    }
  end

  # Subconditions need :fuzzy for spelling suggestions, and :logger to report them
  def metadata!(key, value)
    super
    @conds.each{|cond| cond.metadata!(key, value)}
  end

  def to_s
    "lore:#{maybe_quote(@query)}"
  end

  def explain(negated: false)
    conjunction = negated ? "and" : "or"
    verb = negated ? "doesn't mention" : "mentions"
    %[the name, type, #{conjunction} flavor text #{verb} "#{@query}"]
  end
end

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

  def to_s
    "lore:#{maybe_quote(@query)}"
  end
end

class ConditionKeyword < ConditionSimple
  def initialize(keyword)
    @keyword = keyword.downcase
  end

  def match?(card)
    card.keywords && card.keywords.include?(@keyword)
  end

  def to_s
    "keyword:#{maybe_quote(@keyword)}"
  end

  def explain(negated: false)
    "the card #{negated ? "doesn't have" : "has"} the #{@keyword} keyword"
  end
end

class ConditionWord < ConditionSimple
  def initialize(word)
    @word = normalize_name(word)
  end

  def match?(card)
    normalize_name(card.name).include?(@word)
  end

  def to_s
    "#{maybe_quote(@word)}"
  end
end

class ConditionOracle < Condition
  def initialize(text)
    @text = text
  end

  def match?(card)
    normalize_text(card.text).include?(normalize_text(@text.gsub("~", card.name)))
  end

  def to_s
    "o:#{maybe_quote(@text)}"
  end
end

class ConditionOracle < ConditionSimple
  def initialize(text)
    @text = text
    @has_cardname = !!(@text =~ /~/)
    @normalized_text = normalize_text(@text)
  end

  def match?(card)
    if @has_cardname
      card.text.downcase.include?(@text.gsub("~", normalize_text(card.name)))
    else
      card.text.downcase.include?(@normalized_text)
    end
  end

  def to_s
    "o:#{maybe_quote(@text)}"
  end
end

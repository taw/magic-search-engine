class ConditionOracle < ConditionSimple
  def initialize(text)
    @text = text
    @has_cardname = !!(@text =~ /~/)
    @regexp = build_regexp(normalize_text(@text))
  end

  def match?(card)
    if @has_cardname
      card.text =~ build_regexp(normalize_text(@text.gsub("~", card.name)))
    else
      card.text =~ @regexp
    end
  end

  def to_s
    "o:#{maybe_quote(@text)}"
  end

  private

  def build_regexp(text)
    Regexp.new(Regexp.escape(text), Regexp::IGNORECASE)
  end
end

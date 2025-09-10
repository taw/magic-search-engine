class ConditionFullOracle < ConditionOracle
  def match?(card)
    if @has_cardname
      card.fulltext_normalized =~ build_regexp(normalize_text(@text.gsub("~", card.name)))
    else
      card.fulltext_normalized =~ @regexp
    end
  end

  def to_s
    "fo:#{maybe_quote(@text)}"
  end
end

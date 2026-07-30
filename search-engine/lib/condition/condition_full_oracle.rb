class ConditionFullOracle < ConditionOracle
  def match?(card)
    if @has_cardname
      # Reminder text uses short names too - "whenever B.O.B. gains or loses loyalty"
      card.fulltext_normalized =~ Regexp.new(@base_rx_str.gsub("~", "(?:#{names_rx_str(card)})"), Regexp::IGNORECASE)
    else
      card.fulltext_normalized =~ @regexp
    end
  end

  def to_s
    "fo:#{maybe_quote(@text)}"
  end
end

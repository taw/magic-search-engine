class ConditionFullOracleRegexp < ConditionRegexp
  def match?(card)
    card.fulltext =~ @regexp
  end

  def to_s
    "fo:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end

  private

  def field_description
    "the Oracle text, including reminder text,"
  end
end

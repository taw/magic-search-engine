class ConditionOracleRegexp < ConditionRegexp
  def match?(card)
    card.text =~ @regexp
  end

  def to_s
    "o:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end

  private

  def field_description
    "the Oracle text"
  end
end

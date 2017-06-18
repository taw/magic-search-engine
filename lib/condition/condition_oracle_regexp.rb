class ConditionOracleRegexp < ConditionRegexp
  def match?(card)
    card.text =~ @regexp
  end

  def to_s
    "o:#{@regexp.inspect.sub(/i\z/, "")}"
  end
end

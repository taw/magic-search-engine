class ConditionNumberRegexp < ConditionRegexp
  def match?(card)
    card.number.to_s =~ @regexp
  end

  def to_s
    "number:#{@regexp.inspect.sub(/i\z/, "")}"
  end
end

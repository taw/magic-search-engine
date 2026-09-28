class ConditionNumberRegexp < ConditionRegexp
  def match?(card)
    card.number =~ @regexp
  end

  def to_s
    "number:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end

  private

  def field_description
    "the collector number"
  end
end

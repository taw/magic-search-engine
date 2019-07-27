class ConditionNameRegexp < ConditionRegexp
  def match?(card)
    card.name =~ @regexp
  end

  def to_s
    "n:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end
end

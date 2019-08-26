class ConditionFlavorRegexp < ConditionRegexp
  def match?(card)
    card.flavor =~ @regexp
  end

  def to_s
    "ft:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end
end

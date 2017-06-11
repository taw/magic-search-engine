class ConditionFlavorRegexp < ConditionRegexp
  def match?(card)
    card.flavor =~ @regexp
  end

  def to_s
    "ft:#{@regexp.inspect}"
  end
end

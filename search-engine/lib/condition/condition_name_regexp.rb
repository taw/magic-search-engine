class ConditionNameRegexp < ConditionRegexp
  def match?(card)
    card.name =~ @regexp
  end

  def to_s
    "n:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end

  private

  def field_description
    "the name"
  end
end

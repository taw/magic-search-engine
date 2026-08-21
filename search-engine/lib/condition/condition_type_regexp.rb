# Unlike every other type query this one cares about the printed order of the
# type words, and about the separator, which is a plain "-" here - not the em
# dash of the real type line, which nobody can type.
class ConditionTypeRegexp < ConditionRegexp
  def match?(card)
    card.typeline =~ @regexp
  end

  def to_s
    "t:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end
end

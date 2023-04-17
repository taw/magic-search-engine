class ConditionStamp < ConditionSimple
  def initialize(stamp)
    @stamp = stamp.downcase
  end

  def match?(card)
    if @stamp == "*"
      !!card.stamp
    else
      card.stamp == @stamp
    end
  end

  def to_s
    "stamp:#{maybe_quote(@stamp)}"
  end
end

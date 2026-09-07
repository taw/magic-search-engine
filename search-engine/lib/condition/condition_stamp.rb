class ConditionStamp < ConditionSimple
  def initialize(stamp)
    @stamp = stamp.downcase
    @any = (@stamp == "*")
  end

  def match?(card)
    if @any
      !!card.stamp
    else
      card.stamp == @stamp
    end
  end

  def to_s
    "stamp:#{maybe_quote(@stamp)}"
  end
end

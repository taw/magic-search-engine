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

  def explain(negated: false)
    if @any
      negated ? "the card has no security stamp" : "the card has a security stamp"
    else
      "the card #{negated ? "doesn't have" : "has"} the #{@stamp} security stamp"
    end
  end
end

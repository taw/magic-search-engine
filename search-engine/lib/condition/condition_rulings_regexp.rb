class ConditionRulingsRegexp < ConditionRegexp
  def match?(card)
    card.rulings and card.rulings.any?{|r| r["text"] =~ @regexp}
  end

  def to_s
    "rulings:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end
end

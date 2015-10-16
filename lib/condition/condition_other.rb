class ConditionOther < Condition
  def initialize(cond)
    @cond = cond
  end

  def match?(card)
    card.others and card.others.any?{|c| @cond.match?(c)}
  end

  def to_s
    "other:#{@cond}"
  end
end

class ConditionPart < Condition
  def initialize(cond)
    @cond = cond
  end

  def match?(card)
    card.others and (@cond.match?(card) or card.others.any?{|c| @cond.match?(c)})
  end

  def to_s
    "part:#{@cond}"
  end
end

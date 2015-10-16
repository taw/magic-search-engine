class ConditionAnd < Condition
  def initialize(*conds)
    @conds = *conds
  end

  def include_extras?
    @conds.any?(&:include_extras?)
  end

  def match?(card)
    @conds.all?{|c| c.match?(card)}
  end

  def to_s
    "(#{@conds.join(' ')})"
  end
end

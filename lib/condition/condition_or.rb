class ConditionOr < Condition
  def initialize(*conds)
    @conds = *conds
    raise if @conds.empty?
  end

  def include_extras?
    @conds.any?(&:include_extras?)
  end

  def search(db)
    @conds.map{|cond| cond.search(db)}.inject(&:|)
  end

  def to_s
    "(#{@conds.join(' or ')})"
  end
end

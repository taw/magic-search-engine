class ConditionNot < Condition
  def initialize(cond)
    @cond = cond
  end

  def include_extras?
    @cond.include_extras?
  end

  def match?(card)
    not @cond.match?(card)
  end

  def to_s
    "not #{@cond}"
  end
end

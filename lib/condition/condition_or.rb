class ConditionOr < Condition
  attr_reader :conds
  def initialize(*conds)
    @conds = conds.map do |c|
      if c.is_a?(ConditionOr)
        c.conds
      else
        [c]
      end
    end.flatten
    raise if @conds.empty?
    @simple = @conds.all?(&:simple?)
  end

  def include_extras?
    @conds.any?(&:include_extras?)
  end

  def search(db)
    @conds.map{|cond| cond.search(db)}.inject(&:|)
  end

  def match?(card)
    raise unless @simple
    @conds.any?{|cond| cond.match?(card)}
  end

  def metadata=(options)
    super
    @conds.each{|cond| cond.metadata = options}
  end

  def simple?
    @simple
  end

  def to_s
    "(#{@conds.join(' or ')})"
  end
end

class ConditionAnd < Condition
  attr_reader :conds
  def initialize(*conds)
    @conds = conds.map do |c|
      if c.is_a?(ConditionAnd)
        c.conds
      else
        [c]
      end
    end.flatten
    raise if @conds.empty?
    @simple_conds, @special_conds = @conds.partition{|c| c.is_a?(ConditionSimple) }
  end

  def include_extras?
    @conds.any?(&:include_extras?)
  end

  def search(db)
    if @special_conds.empty?
      results = db.printings
    else
      results = @special_conds.map{|cond| cond.search(db)}.inject(&:&)
    end
    @simple_conds.each do |cond|
      results = Set.new(results.select{|card| cond.match?(card) })
    end
    results
  end

  def to_s
    "(#{@conds.join(' ')})"
  end
end

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
    @simple_conds, @special_conds = @conds.partition(&:simple?)
    @simple = @conds.all?(&:simple?)
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
      results = results.select{|card| cond.match?(card) }
    end
    results.to_set
  rescue
    require 'pry'; binding.pry
  end

  def match?(card)
    raise unless @simple
    @conds.all?{|cond| cond.match?(card)}
  end

  def metadata=(options)
    @conds.each{|cond| cond.metadata = options}
  end

  def simple?
    @simple
  end

  def to_s
    "(#{@conds.join(' ')})"
  end
end

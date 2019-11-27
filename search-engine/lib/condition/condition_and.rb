class ConditionAnd < Condition
  attr_reader :conds

  def initialize(*conds)
    @conds = conds.compact.uniq.map do |c|
      if c.is_a?(ConditionAnd)
        c.conds
      else
        [c]
      end
    end.flatten.uniq
    raise if @conds.empty?
    @simple_conds, @special_conds = @conds.partition(&:simple?)
    @simple = @conds.all?(&:simple?)
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
  end

  def match?(card)
    raise unless @simple
    @conds.all?{|cond| cond.match?(card)}
  end

  def metadata!(key, value)
    super
    @conds.each{|cond| cond.metadata!(key, value)}
  end

  def simple?
    @simple
  end

  def to_s
    "(#{@conds.join(' ')})"
  end

  def ==(other)
    self.class == other.class and
      conds.sort_by(&:to_s) == other.conds.sort_by(&:to_s)
  end
end

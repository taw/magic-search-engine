class ConditionAnd < Condition
  attr_reader :conds

  def initialize(*conds)
    @conds = conds.compact.map do |c|
      if c.is_a?(ConditionAnd)
        c.conds
      else
        [c]
      end
    end.flatten.uniq
    raise if @conds.empty?
    @simple_conds, special_conds = @conds.partition(&:simple?)
    # Conditions which can't make use of candidates go first - they cost the same
    # no matter what, and they narrow candidates for everything that follows.
    full_conds, narrowing_conds = special_conds.partition{|cond| !cond.uses_candidates?}
    @special_conds = full_conds + narrowing_conds
    @simple = @conds.all?(&:simple?)
    @uses_candidates = @conds.any?(&:uses_candidates?)
  end

  # Special conditions run first, each one narrowing candidates for the next,
  # so simple conditions only ever match against the smallest set we have.
  def search(db, candidates=db.printings)
    results = candidates
    @special_conds.each do |cond|
      results = cond.search(db, results)
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

  def uses_candidates?
    @uses_candidates
  end

  def to_s
    "(#{@conds.join(' ')})"
  end

  def ==(other)
    self.class == other.class and
      conds.sort_by(&:to_s) == other.conds.sort_by(&:to_s)
  end

  def hash
    [self.class, conds.map(&:hash).sort].hash
  end
end

class ConditionOr < Condition
  attr_reader :conds

  def initialize(*conds)
    @conds = conds.map do |c|
      if c.is_a?(ConditionOr)
        c.conds
      else
        [c]
      end
    end.flatten.uniq
    raise if @conds.empty?
    setup_conds!
  end

  # All simple conditions can be checked in a single pass over candidates,
  # instead of a full db search plus a set merge for each of them.
  def search(db, candidates=db.printings)
    subresults = @special_conds.map{|cond| cond.search(db, candidates)}
    unless @simple_conds.empty?
      subresults << candidates.select{|card| @simple_conds.any?{|cond| cond.match?(card)} }.to_set
    end
    merge_into_set subresults
  end

  def match?(card)
    raise unless @simple
    @conds.any?{|cond| cond.match?(card)}
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
    "(#{@conds.join(' or ')})"
  end

  def ==(other)
    self.class == other.class and
      conds.sort_by(&:to_s) == other.conds.sort_by(&:to_s)
  end

  def hash
    [self.class, conds.map(&:hash).sort].hash
  end

  # Subclasses which build @conds themselves need to call this
  def setup_conds!
    @simple_conds, @special_conds = @conds.partition(&:simple?)
    @simple = @special_conds.empty?
    @uses_candidates = @conds.any?(&:uses_candidates?)
  end
end

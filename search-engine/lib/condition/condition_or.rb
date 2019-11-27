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
    @simple = @conds.all?(&:simple?)
  end

  def search(db)
    merge_into_set @conds.map{|cond| cond.search(db)}
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

  def to_s
    "(#{@conds.join(' or ')})"
  end

  def ==(other)
    self.class == other.class and
      conds.sort_by(&:to_s) == other.conds.sort_by(&:to_s)
  end
end

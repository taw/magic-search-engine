class ConditionNot < Condition
  def initialize(cond)
    @cond = cond
    @simple = @cond.simple?
  end

  def search(db, candidates=db.printings)
    if @simple
      candidates.to_a.reject{|card| @cond.match?(card)}.to_set
    else
      candidates - @cond.search(db, candidates)
    end
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def match?(card)
    raise unless @simple
    not @cond.match?(card)
  end

  def simple?
    @simple
  end

  def uses_candidates?
    true
  end

  def to_s
    "-(#{@cond})"
  end
end

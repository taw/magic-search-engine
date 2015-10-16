class ConditionNot < Condition
  def initialize(cond)
    @cond = cond
    @simple = @cond.simple?
  end

  def include_extras?
    @cond.include_extras?
  end

  def search(db, metadata)
    db.printings - @cond.search(db, metadata)
  end

  def match?(card)
    raise unless @simple
    not @cond.match?(card)
  end

  def simple?
    @simple
  end

  def to_s
    "(not #{@cond})"
  end
end

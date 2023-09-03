class ConditionNot < Condition
  def initialize(cond)
    @cond = cond
    @simple = @cond.simple?
  end

  def search(db)
    db.printings - @cond.search(db)
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

  def to_s
    "-(#{@cond})"
  end
end

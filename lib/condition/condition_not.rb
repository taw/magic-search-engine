class ConditionNot < ConditionSimple
  def initialize(cond)
    @cond = cond
  end

  def include_extras?
    @cond.include_extras?
  end

  def search(db)
    db.printings - @cond.search(db)
  end

  def to_s
    "not #{@cond}"
  end
end

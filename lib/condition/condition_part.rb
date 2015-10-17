class ConditionPart < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    @cond.search(db).map{|c| c.others ? Set[c, *c.others] : Set[]}.inject(Set[], &:|)
  end

  def metadata=(options)
    @cond.metadata = options
  end

  def to_s
    "part:#{@cond}"
  end
end

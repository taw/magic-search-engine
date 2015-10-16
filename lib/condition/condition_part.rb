class ConditionPart < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db, metadata)
    @cond.search(db, metadata).map{|c| c.others ? Set[c, *c.others] : Set[]}.inject(Set[], &:|)
  end

  def to_s
    "part:#{@cond}"
  end
end

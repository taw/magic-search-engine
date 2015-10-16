class ConditionOther < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db, metadata)
    @cond.search(db, metadata).map{|c| c.others ? Set[*c.others] : Set[]}.inject(Set[], &:|)
  end

  def to_s
    "other:#{@cond}"
  end
end

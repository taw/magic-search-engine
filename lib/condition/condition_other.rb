class ConditionOther < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    @cond.search(db).map{|c| c.others ? Set[*c.others] : Set[]}.inject(Set[], &:|)
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "other:#{@cond}"
  end
end

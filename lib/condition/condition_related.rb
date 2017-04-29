class ConditionRelated < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    @cond.search(db).map{|c| c.related ? Set[*c.related] : Set[]}.inject(Set[], &:|)
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "related:#{@cond}"
  end
end

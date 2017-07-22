class ConditionOther < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    merge_into_set @cond.search(db).map{|c| c.others ? Set[*c.others] : Set[]}
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "other:#{@cond}"
  end
end

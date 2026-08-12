class ConditionOther < Condition
  def initialize(cond)
    @cond = cond
  end

  def search_all(db)
    result = []
    @cond.search(db).each do |c|
      result.concat(c.others) if c.others
    end
    result.uniq
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "other:#{@cond}"
  end
end

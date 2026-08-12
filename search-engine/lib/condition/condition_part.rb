class ConditionPart < Condition
  def initialize(cond)
    @cond = cond
  end

  def search_all(db)
    result = []
    @cond.search(db).each do |c|
      if c.others
        result << c
        result.concat(c.others)
      end
    end
    result.uniq
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "part:#{@cond}"
  end
end

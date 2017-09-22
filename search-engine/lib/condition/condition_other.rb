class ConditionOther < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    result = Set[]
    @cond.search(db).each do |c|
      others = c.others
      if others
        others.each do |e|
          result << e
        end
      end
    end
    result
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "other:#{@cond}"
  end
end

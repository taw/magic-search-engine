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

  def explain(negated: false)
    "the card #{negated ? "doesn't have" : "has"} #{explain_part}"
  end

  def explain_part
    if @cond.is_a?(ConditionPart)
      @cond.explain_parts("another part")
    else
      "another part where #{@cond.compound? ? "(#{@cond.explain})" : @cond.explain}"
    end
  end
end

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

  # In part:(a other:b) the other: children become the "another part"
  # clauses, and the rest describes the part that matched.
  def explain(negated: false)
    explanation = "the card has #{explain_parts("a part")}"
    negated ? "not (#{explanation})" : explanation
  end

  # Also used by ConditionOther, so part:(a other:part:(b other:c)) reads as
  # a flat list of parts.
  def explain_parts(first)
    conds = @cond.is_a?(ConditionAnd) ? @cond.conds : [@cond]
    others, own = conds.partition{|c| c.is_a?(ConditionOther)}
    own_explain = own.size == 1 ? explain_clause(own[0]) : "(#{ConditionAnd.new(*own).explain})"
    other_explain = others.empty? ? "another part" : others.map(&:explain_part).join(", and ")
    "#{first} where #{own_explain}, and #{other_explain}"
  end

  private

  def explain_clause(cond)
    cond.compound? ? "(#{cond.explain})" : cond.explain
  end
end

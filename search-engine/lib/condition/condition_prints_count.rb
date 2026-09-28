# How many printings of the card match the subquery.
#
# alt:X is this condition with ">=" and 1, and -alt:X is it with "=" and 0.
# The point of spelling out the count is questions like "cards which got exactly
# two Booster Fun treatments", which otherwise have to be written as a hand
# expanded disjunction over every combination of treatments.
class ConditionPrintsCount < Condition
  def initialize(op, count, cond)
    @op = op
    @count = count
    @cond = cond
  end

  # Unlike ConditionAlt this always filters candidates and never expands the
  # subquery's results - "prints=0:" and "prints<2:" match cards with no matching
  # printing at all, which no amount of looking at the matches would find.
  def search(db, candidates=db.printings)
    counts = counts_per_card(db)
    candidates.select{|printing| matches?(counts[printing.card])}
  end

  def uses_candidates?
    true
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "prints#{@op}#{@count}:#{@cond}"
  end

  # Same wording as plain prints>=N, which is a ConditionExpr
  def explain(negated: false)
    words = negated ? ConditionExpr::NEGATED_OP_WORDS : ConditionExpr::OP_WORDS
    "the number of printings matching (#{@cond.explain}) #{words.fetch(@op)} #{@count}"
  end

  private

  # The subquery has to see the whole db - counting only the candidates would
  # answer a different question
  def counts_per_card(db)
    counts = Hash.new(0)
    @cond.search(db).each do |printing|
      counts[printing.card] += 1
    end
    counts
  end

  def matches?(found)
    case @op
    when "="
      found == @count
    when ">="
      found >= @count
    when ">"
      found > @count
    when "<="
      found <= @count
    when "<"
      found < @count
    else
      raise "Prints count comparison parse error: #{@op}"
    end
  end
end

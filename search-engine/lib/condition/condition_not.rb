class ConditionNot < Condition
  def initialize(cond)
    @cond = cond
    @simple = @cond.simple?
  end

  def search(db, candidates=db.printings)
    if @simple
      candidates.reject{|card| @cond.match?(card)}
    else
      candidates - @cond.search(db, candidates)
    end
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def match?(card)
    raise unless @simple
    not @cond.match?(card)
  end

  def simple?
    @simple
  end

  def uses_candidates?
    true
  end

  def to_s
    "-(#{@cond})"
  end

  # Deliberately just "not (...)", with no leading "and" - the parent AND/OR owns
  # the connector between clauses, so this composes cleanly whether it's the only
  # condition or one of several (unlike Scryfall's explain, which bakes "and" into
  # the NOT clause itself and ends up with "X and and not (Y)").
  def explain
    "not (#{@cond.explain})"
  end
end

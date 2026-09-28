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

  def compound?
    true
  end

  # Deliberately no leading "and" - the parent AND/OR owns the connector between
  # clauses, so this composes cleanly whether it's the only condition or one of
  # several (unlike Scryfall's explain, which bakes "and" into the NOT clause itself
  # and ends up with "X and and not (Y)").
  #
  # A single condition (not itself an AND/OR/NOT) reads far better negated in place -
  # "the card is not a spell" beats "not (the card is a spell)", and that only gets
  # worse nested inside a bigger query. Only compound children still get wrapped in
  # "not (...)", since flipping their polarity correctly needs De Morgan's law, not
  # a single flipped phrase.
  def explain
    @cond.compound? ? "not (#{@cond.explain})" : @cond.explain(negated: true)
  end
end

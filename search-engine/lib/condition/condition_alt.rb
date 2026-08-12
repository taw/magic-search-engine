class ConditionAlt < Condition
  def initialize(cond)
    @cond = cond
  end

  # All printings of every card which has any printing matching @cond.
  #
  # For a simple @cond this is one pass over candidates, checking printings of
  # each card just once - no need to look at the whole db at all.
  # Otherwise we do need a full search, but restricted to candidates we only
  # have to filter its result, not expand it to every printing of every card.
  def search(db, candidates=db.printings)
    return search_simple(candidates) if @cond.simple?

    matching = matching_cards(db)
    if candidates.equal?(db.printings)
      results = []
      matching.each{|card| results.concat(card.printings)}
      results
    else
      candidates.select{|printing| matching.include?(printing.card)}
    end
  end

  def uses_candidates?
    @cond.simple?
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "alt:#{@cond}"
  end

  private

  def search_simple(candidates)
    known = {}
    candidates.select do |printing|
      card = printing.card
      matches = known[card]
      matches = known[card] = card.printings.any?{|cp| @cond.match?(cp)} if matches.nil?
      matches
    end
  end

  def matching_cards(db)
    cards = Set[]
    @cond.search(db).each do |printing|
      cards << printing.card
    end
    cards
  end
end

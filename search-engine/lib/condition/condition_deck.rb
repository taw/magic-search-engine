class ConditionDeck < Condition
  # We used to have "allowed conflicts" logic so basics from the same set would match
  # but this is no longer necessary.

  BasicLands = [
    "Plains",
    "Island",
    "Swamp",
    "Mountain",
    "Forest",
  ].to_set

  def initialize(deck_name)
    @deck_name = deck_name
  end

  def search_all(db)
    decks = db.resolve_deck_name(@deck_name)
    if decks.empty?
      warning %[No deck matching "#{@deck_name}"]
    elsif decks.size > 1 and decks.size < db.decks.size
      deck_names = decks.map{|deck| "#{deck.name} (#{deck.set_name})"}
      warning %[Multiple decks matching "#{@deck_name}": #{deck_names.join(", ")}]
    end

    results = []

    decks.each do |deck|
      [*deck.cards, *deck.sideboard, *deck.commander].each do |count, card|
        results.concat(card.parts)
      end
    end

    results.uniq
  end

  def to_s
    "deck:#{maybe_quote(@deck_name)}"
  end
end

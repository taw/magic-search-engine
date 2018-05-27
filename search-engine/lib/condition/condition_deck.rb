class ConditionDeck < Condition
  def initialize(deck_name)
    @deck_name = deck_name
  end

  def search(db)
    decks = resolve_deck_name(db)
    if decks.empty?
      warning %Q[No deck matching "#{@deck_name}"]
    elsif decks.size > 1
      deck_names = decks.map{|deck| "#{deck.name} (#{deck.set_name})"}
      warning %Q[Multiple decks matching "#{@deck_name}": #{deck_names.join(", ")}]
    end

    # We don't have printing resolution within same set
    # so we need extra step, so all C17 Forests get included, not just some
    matching_card_names = {}
    decks.each do |deck|
      [*deck.cards, *deck.sideboard].each do |count, card|
        card.parts.each do |cp|
          matching_card_names[cp.set_code] ||= Set.new
          matching_card_names[cp.set_code] << cp.name
        end
      end
    end

    results = Set[]
    matching_card_names.each do |set_code, matching_names|
      set = db.sets[set_code]
      set.printings.each do |card_printing|
        results << card_printing if matching_names.include?(card_printing.name)
      end
    end

    results
  end

  def to_s
    "deck:#{maybe_quote(@deck_name)}"
  end

  def resolve_deck_name(db)
    deck_name = @deck_name.strip

    if deck_name.include?("/")
      set_query, deck_query = @deck_name.split("/", 2)
      sets = db.resolve_editions(set_query.strip)
      possible_decks = sets.flat_map(&:decks)
    else
      possible_decks = db.decks
      deck_query = deck_name
    end
    deck_query = deck_query.downcase.strip.gsub("'s", "").gsub(",", "")

    decks = possible_decks.select do |deck|
      deck.slug == deck_query
    end
    return decks unless decks.empty?

    decks = possible_decks.select do |deck|
      deck.name.downcase.gsub("'s", "").gsub(",", "") == deck_query
    end
    return decks unless decks.empty?

    normalized_query_words = deck_query.split

    possible_decks.select do |deck|
      normalized_words = deck.name.downcase.gsub("'s", "").gsub(",", "").split
      normalized_query_words.all?{|qw| normalized_words.include?(qw)}
    end
  end
end

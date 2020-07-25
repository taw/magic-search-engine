class ConditionDeck < Condition
  def initialize(deck_name)
    @deck_name = deck_name
  end

  def search(db)
    decks = db.resolve_deck_name(@deck_name)
    if decks.empty?
      warning %Q[No deck matching "#{@deck_name}"]
    elsif decks.size > 1
      deck_names = decks.map{|deck| "#{deck.name} (#{deck.set_name})"}
      warning %Q[Multiple decks matching "#{@deck_name}": #{deck_names.join(", ")}]
    end

    # FIXME:
    # This is true only for non-special basics (plus Wastes and guildgates).
    # Everything else should have exact resolution.
    #
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
end

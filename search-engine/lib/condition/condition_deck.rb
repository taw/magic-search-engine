class ConditionDeck < Condition
  # This list should match CardsWithAllowedConflicts in DeckPrintingResolver
  # For these we don't have exact printing information, so any printing from
  # the same set will be considered matching
  #
  # There's two algorithms:
  # * for cards with allowed conflicts, we only know from which set they are, not exact printing
  # * for all other cards, we know exact printing

  CardsWithAllowedConflicts = [
    "Plains",
    "Island",
    "Swamp",
    "Mountain",
    "Forest",
    "Wastes",
    "Azorius Guildgate",
    "Boros Guildgate",
    "Dimir Guildgate",
    "Golgari Guildgate",
    "Gruul Guildgate",
    "Izzet Guildgate",
    "Orzhov Guildgate",
    "Rakdos Guildgate",
    "Selesnya Guildgate",
    "Simic Guildgate",
  ].to_set

  def initialize(deck_name)
    @deck_name = deck_name
  end

  def search(db)
    decks = db.resolve_deck_name(@deck_name)
    if decks.empty?
      warning %[No deck matching "#{@deck_name}"]
    elsif decks.size > 1 and decks.size < db.decks.size
      deck_names = decks.map{|deck| "#{deck.name} (#{deck.set_name})"}
      warning %[Multiple decks matching "#{@deck_name}": #{deck_names.join(", ")}]
    end

    # For exact matching
    results = Set[]
    # For inexact matching
    matching_card_names = {}

    decks.each do |deck|
      [*deck.cards, *deck.sideboard, *deck.commander].each do |count, card|
        card.parts.each do |cp|
          if CardsWithAllowedConflicts.include?(cp.name)
            matching_card_names[cp.set_code] ||= Set.new
            matching_card_names[cp.set_code] << cp.name
          else
            results << cp
          end
        end
      end
    end

    # Expand inexact matches
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

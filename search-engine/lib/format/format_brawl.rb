class FormatBrawl < FormatStandard
  def format_pretty_name
    "Brawl"
  end

  def deck_issues(deck)
    [
      *deck_size_issues(deck),
      *deck_card_issues(deck),
      *deck_commander_issues(deck),
      *deck_color_identity_issues(deck),
    ]
  end

  def deck_size_issues(deck)
    issues = []
    if deck.number_of_total_cards != 60
      issues << "Deck must contain exactly 60 cards, has #{deck.number_of_total_cards}"
    end
    unless deck.number_of_sideboard_cards.between?(1, 2)
      issues << "Deck's sideboard must be exactly 1 card or 2 partner cards designated as commander, has #{deck.number_of_sideboard_cards}"
    end
    issues
  end

  def deck_card_issues(deck)
    issues = []
    deck.card_counts.each do |card, name, count|
      card_legality = legality(card)
      case card_legality
      when "legal", "restricted"
        if count > 1 and not card.allowed_in_any_number?
          issues << "Deck contains #{count} copies of #{name}, only up to 1 allowed"
        end
      when "banned"
        issues << "#{name} is banned"
      else
        issues << "#{name} is not in the format"
      end
    end
    issues
  end

  def deck_commander_issues(deck)
    cards = deck.sideboard.flat_map{|n,c| [c] * n}
    return [] unless cards.size.between?(1, 2)

    issues = []
    cards.each do |c|
      if not c.brawler?
        issues << "#{c.name} is not a valid commander"
      elsif legality(c) == "restricted"
        issues << "#{c.name} is banned as commander"
      end
    end

    # Brawl never had any partners, it's copy&pasted commander logic
    if cards.size == 2
      a, b = cards
      issues << "#{a.name} is not a valid partner card" unless a.partner?
      issues << "#{b.name} is not a valid partner card" unless b.partner?
      if a.partner and a.partner.name != b.name
        issues << "#{a.name} can only partner with #{a.partner.name}"
      end
      if b.partner and b.partner.name != a.name
        issues << "#{b.name} can only partner with #{b.partner.name}"
      end
    end

    issues
  end

  def deck_color_identity_issues(deck)
    color_identity = deck.color_identity
    return [] unless color_identity
    color_identity = color_identity.chars.to_set
    issues = []
    basics = Set[]
    deck.card_counts.each do |card, name, count|
      card_color_identity = card.color_identity.chars.to_set
      next if card_color_identity <= color_identity
      if color_identity.empty? and card.types.include?("basic")
        basics << card_color_identity
      else
        issues << "#{name} is outside deck color identity"
      end
    end
    if basics.size > 1
      issues << "Deck with colorless commander can contain basic lands of only one color"
    end
    issues
  end

  def deck_legality(deck)
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card).nil? }
    return "#{offending_card.name} is not legal in #{format_pretty_name}." unless offending_card.nil?
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card) == "banned" }
    return "#{offending_card.name} is banned in #{format_pretty_name}." unless offending_card.nil?
    return "The deck commander must be in the sideboard, but this deck's sideboard is empty." if deck.number_of_sideboard_cards == 0
    return "A deck can only have one commander (or two partner commanders), but this deck has #{deck.number_of_sideboard_cards}." if deck.number_of_sideboard_cards > 2
    if deck.number_of_sideboard_cards == 2
      first_partner, second_partner = deck.sideboard.map(&:last).map(&:main_front)
      return "#{first_partner.name} does not partner with #{second_partner.name}." unless first_partner.partner? and (first_partner.partner.nil? or first_partner.partner.card == second_partner.card)
      return "#{second_partner.name} does not partner with #{first_partner.name}." unless second_partner.partner? and (second_partner.partner.nil? or second_partner.partner.card == first_partner.card)
    end
    offending_card = deck.sideboard.map(&:last).map(&:main_front).find{|card| !card.types.include?("legendary") or (!card.types.include?("creature") and !card.types.include?("planeswalker")) }
    return "#{offending_card.name} can't be a commander." unless offending_card.nil?
    offending_card = deck.sideboard.map(&:last).map(&:main_front).find{|card| legality(card) == "restricted" }
    return "#{offending_card.name} is banned as commander in #{format_pretty_name}." unless offending_card.nil?
    mainboard_size = 60 - deck.number_of_sideboard_cards
    return "Mainboard must be exactly #{mainboard_size} cards, but this deck has #{deck.number_of_mainboard_cards}." if deck.number_of_mainboard_cards != mainboard_size
    offending_card = deck.physical_cards.map(&:main_front).find{|card| !card.allowed_in_any_number? && deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == card.name}.map(&:first).inject(0, &:+) > 1 }
    unless offending_card.nil?
      count = deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == offending_card.name}.map(&:first).inject(0, &:+)
      return "A maximum of one copy of the same nonbasic card is allowed, but this deck has #{count} copies of #{offending_card.name}."
    end
    deck_color_identity = deck.sideboard.map(&:last).map(&:color_identity).flat_map(&:chars).to_set
    if deck_color_identity.empty?
      first_basic_land = deck.mainboard.map(&:last).find{|card| card.types.include?("basic") and card.types.include?("land") and ["plains", "island", "swamp", "mountain", "forest"].any?{|land_type| card.types.include?(land_type) } }
      unless first_basic_land.nil?
        first_basic_land_type = first_basic_land.types.find{|land_type| ["plains", "island", "swamp", "mountain", "forest"].include(land_type) }
        second_basic_land = deck.mainboard.map(&:last).find{|card| card.types.include?("basic") and card.types.include?("land") and ["plains", "island", "swamp", "mountain", "forest"].any?{|land_type| land_type != first_basic_land_type && card.types.include?(land_type) } }
        unless second_basic_land.nil?
          second_basic_land_type = second_basic_land.types.find{|land_type| land_type != first_basic_land_type && ["plains", "island", "swamp", "mountain", "forest"].include(land_type) }
          return "#{format_pretty_name} decks with a colorless color identity may only include basic lands of a single basic land type, but this deck has both #{first_basic_land_type} and #{second_basic_land_type}."
        end
      end
      offending_card = deck.mainboard.map(&:last).find{|card| !card.color_identity.empty? and (!card.types.include?("basic") or !card.types.include?("land")) } # assumes that basic lands can only get their color identity from their basic land type
      return "The deck has a colorless color identity, but #{offending_card.name} has a color identity of #{color_identity_name(offending_card.color_identity.chars.to_set)}." unless offending_card.nil?
    else
      offending_card = deck.mainboard.map(&:last).find{|card| !(card.color_identity.chars.to_set <= deck_color_identity) }
      return "The deck has a color identity of #{color_identity_name(deck_color_identity)}, but #{offending_card.name} has a color identity of #{color_identity_name(offending_card.color_identity.chars.to_set)}." unless offending_card.nil?
    end
  end
end

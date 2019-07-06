class FormatCommander < FormatVintage
  def format_pretty_name
    "Commander"
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
    if deck.number_of_total_cards != 100
      issues << "Deck must contain exactly 100 cards, has #{deck.number_of_total_cards}"
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
      if not c.commander?
        issues << "#{c.name} is not a valid commander"
      elsif legality(c) == "restricted"
        issues << "#{c.name} is banned as commander"
      end
    end

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
    deck.card_counts.each do |card, name, count|
      card_color_identity = card.color_identity.chars.to_set
      unless card_color_identity <= color_identity
        issues << "#{name} is outside deck color identity"
      end
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
    offending_card = deck.sideboard.map(&:last).map(&:main_front).find{|card| (!card.types.include?("legendary") or !card.types.include?("creature")) and (!card.types.include?("planeswalker") or card.text !~ /\bcan be your commander\b/) }
    return "#{offending_card.name} can't be a commander." unless offending_card.nil?
    offending_card = deck.sideboard.map(&:last).map(&:main_front).find{|card| legality(card) == "restricted" }
    return "#{offending_card.name} is banned as commander in #{format_pretty_name}." unless offending_card.nil?
    mainboard_size = 100 - deck.number_of_sideboard_cards
    return "Mainboard must be exactly #{mainboard_size} cards, but this deck has #{deck.number_of_mainboard_cards}." if deck.number_of_mainboard_cards != mainboard_size
    offending_card = deck.physical_cards.map(&:main_front).find{|card| !card.allowed_in_any_number? && deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == card.name}.map(&:first).inject(0, &:+) > 1 }
    unless offending_card.nil?
      count = deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == offending_card.name}.map(&:first).inject(0, &:+)
      return "A maximum of one copy of the same nonbasic card is allowed, but this deck has #{count} copies of #{offending_card.name}."
    end
    deck_color_identity = deck.sideboard.map(&:last).map(&:color_identity).flat_map(&:chars).to_set
    offending_card = deck.mainboard.map(&:last).find{|card| !(card.color_identity.chars.to_set <= deck_color_identity) }
    return "The deck has a color identity of #{color_identity_name(deck_color_identity)}, but #{offending_card.name} has a color identity of #{color_identity_name(offending_card.color_identity.chars.to_set)}." unless offending_card.nil?
  end

  private

  def color_identity_name(color_identity)
    names = {"w" => "white", "u" => "blue", "b" => "black", "r" => "red", "g" => "green"}
    color_identity = names.map{|c,cv| color_identity.include?(c) ? cv : nil}.compact
    #TODO canonical color order
    case color_identity.size
    when 0
      "colorless"
    when 1, 2
      color_identity.join(" and ")
    when 3
      a, b, c = color_identity
      "#{a}, #{b}, and #{c}"
    when 4
      a, b, c, d = color_identity
      "#{a}, #{b}, #{c}, and #{d}"
    when 5
      "all colors"
    else
      raise
    end
  end
end

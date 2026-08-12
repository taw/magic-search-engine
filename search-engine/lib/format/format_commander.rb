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
    unless deck.number_of_commander_cards.between?(1, 2)
      issues << "Deck's commander must be exactly 1 card or 2 partner cards designated as commander, has #{deck.number_of_commander_cards}"
    end
    unless deck.number_of_sideboard_cards == 0
      issues << "Deck cannot have sideboard, has #{deck.number_of_sideboard_cards} (1-2 card sideboard is treated as commander not sideboard)"
    end
    issues
  end

  def default_max_copies_allowed
    1
  end

  def deck_commander_issues(deck)
    cards = deck.commander.flat_map{|n,c| [c] * n}
    return [] unless cards.size.between?(1, 2)

    issues = []
    cards.each do |c|
      if not c.commander?
        issues << "#{c.name} is not a valid commander"
      elsif legality(c) == "banned_as_commander"
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
end

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
    unless deck.number_of_commander_cards.between?(1, 2)
      issues << "Deck's commander must be exactly 1 card or 2 partner cards designated as commander, has #{deck.number_of_commander_cards}"
    end
    unless deck.number_of_sideboard_cards == 0
      issues << "Deck cannot have sideboard, has #{deck.number_of_sideboard_cards} (1-2 card sideboard is treated as commander not sideboard)"
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
    cards = deck.commander.flat_map{|n,c| [c] * n}
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

  def permanently_legal_cards?
    @time.nil? or @time >= Date.parse("2022-09-09")
  end

  # https://www.reddit.com/r/MagicArena/comments/tge9hb/did_brawl_legality_change_arena_doesnt_seem_to/i11ntcx/
  def in_format?(card)
    if permanently_legal_cards?
      ["Arcane Signet", "Command Tower"].include?(card.name) or super
    else
      super
    end
  end

  def cards_probably_in_format(db)
    if permanently_legal_cards?
      results = super
      results << db.cards["command tower"]
      results << db.cards["arcane signet"]
      results
    else
      super
    end
  end
end

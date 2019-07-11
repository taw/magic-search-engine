class FormatBrawl < FormatStandard
  def format_pretty_name
    "Brawl"
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
        issues << "Deck contains #{name} which is banned"
      else
        issues << "Deck contains #{name} which is not in the format"
      end
    end
    issues
  end
end

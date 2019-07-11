class FormatCommander < FormatVintage
  def format_pretty_name
    "Commander"
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
end

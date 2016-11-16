class FormatPennyDreadful < FormatVintage
  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      return true if PrimaryCards.include?(printing.name)
      if printing.others
        printing.others.each do |other|
          return true if PrimaryCards.include?(other.name)
        end
      end
    end
    false
  end

  def format_pretty_name
    "Penny Dreadful"
  end

  # specs validate that all card names match the database
  def self.load_cards
    cards_file = (Pathname(__dir__).parent.parent + "data/penny_dreadful_legal_cards.txt")
    cards_file.readlines.map(&:chomp).flat_map{|name|
      name.tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu").split(%r[\s*//\s*])
    }.to_set
  end

  # Awkwardly preprocessing this list requires full database
  def self.all_cards(db)
    result = PrimaryCards.dup
    PrimaryCards.each do |card_name|
      printing = db.cards[card_name.downcase].printings[0]
      next unless printing.others
      printing.others.each do |other|
        result << other.name
      end
    end
    result
  end
  PrimaryCards = load_cards
end

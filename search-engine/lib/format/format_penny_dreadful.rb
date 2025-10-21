class FormatPennyDreadful < FormatVintage
  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      return true if PrimaryCards.include?(printing.name)
      return true if PrimaryCards.include?(printing.flavor_name)
      if printing.others
        return true if printing.others.all? do |other|
          PrimaryCards.include?(other.name) ||
          PrimaryCards.include?(other.flavor_name)
        end
      end
    end
    false
  end

  def format_pretty_name
    "Penny Dreadful"
  end

  # specs validate that all card names match the database
  # some of these are flavor names
  def self.load_cards
    cards_file = (Pathname(__dir__) + "../../../index/penny_dreadful_legal_cards.txt")
    cards_file.readlines.map(&:chomp).flat_map{|name|
      if name == "SP//dr, Piloted by Peni"
        [name]
      else
        name.split(%r[\s*//\s*])
      end
    }.to_set
  end

  PrimaryCards = load_cards
end

class DeckParser
  # For testing only:
  attr_reader :lines, :main, :side

  attr_reader :main_cards, :sideboard_cards

  def initialize(db, text)
    @db = db
    @text = text
    @lines = text.sub(/\A\s+/, "").sub(/\s+\z/, "").lines.map(&:chomp).map(&:strip)
    preparse
    resolve
  end

  # This method is really messy, but is has decent test coverage
  def preparse
    in_sideboard = false
    @main = []
    @side = []
    current = @main
    @lines.each do |line|
      foil = nil
      set = nil
      number = nil
      next if line =~ /\A\s*[#\/]/
      # In some decklist formats empty line separates sideboard
      next if line.empty?
      if line =~ /\Asideboard\z/i
        current = @side
        next
      end
      if line =~ /\ASB:\s*(.*)/
        target, line = @side, $1
      else
        target = current
      end
      if line =~ /\A(\d+)x?\s*(.*)/
        num, name = $1.to_i, $2
      else
        num, name = 1, line
      end
      while name.sub!(/\s*\[(.*?)\]/, "")
        tag = $1
        case tag
        when /\Afoil\z/i
          foil = true
        when %r[\A(.*)[/:](.*)\z]
          set = $1
          number = $2
        else
          set = tag
        end
      end
      target << {name: name, count: num, set: set, number: number, foil: foil}.compact
    end
  end

  def resolve
    @main_cards = @main.map do |card_description|
      [card_description[:count], resolve_card(card_description)]
    end.select(&:last)

    @sideboard_cards = @side.map do |card_description|
      [card_description[:count], resolve_card(card_description)]
    end.select(&:last)
  end

  private

  def resolve_card(card_description)
    name = card_description[:name]
    foil = !!card_description[:foil]
    card = @db.cards[normalize_name(name)]
    if card
      printing = card.printings.min_by(&:default_sort_index)
      return PhysicalCard.for(printing, foil)
    end
    parts = name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    if parts.size > 1
      card = @db.cards[parts[0]]
      if card
        printing = card.printings.min_by(&:default_sort_index)
        return PhysicalCard.for(printing, foil)
      end
    end

    # Not tracking foils for that
    return UnknownCard.new(name)
  end

  # These method seem to occur in every single class out there
  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end
end

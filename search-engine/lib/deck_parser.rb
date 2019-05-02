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

  def preparse
    in_sideboard = false
    @main = Hash.new(0)
    @side = Hash.new(0)
    current = @main
    @lines.each do |line|
      next if line =~ /\A[#\/]/
      # In some decklist formats empty line separates sideboard
      next if line.empty?
      if line =~ /\Asideboard\z/i
        current = @side
        next
      end
      if line =~ /\A(\d+)x?\s*(.*)/
        num, name = $1.to_i, $2
      else
        num, name = 1, line
      end
      name.gsub!(/\s*\[.*?\]/, "")
      current[name] += num
    end
  end

  def resolve
    @main_cards = @main.map do |name, num|
      [num, resolve_card(name)]
    end.select(&:last)

    @sideboard_cards = @side.map do |name, num|
      [num, resolve_card(name)]
    end.select(&:last)
  end

  private

  def resolve_card(name)
    card = @db.cards[normalize_name(name)]
    if card
      printing = card.printings.min_by(&:default_sort_index)
      return PhysicalCard.for(printing)
    end
    parts = name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    if parts.size > 1
      card = @db.cards[parts[0]]
      if card
        printing = card.printings.min_by(&:default_sort_index)
        return PhysicalCard.for(printing)
      end
    end

    warn "Can't resolve card: #{name}"
    nil
  end

  # These method seem to occur in every single class out there
  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end
end

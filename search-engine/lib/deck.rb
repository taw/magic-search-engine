class Deck
  attr_reader :set, :name, :type, :cards, :sideboard, :slug
  def initialize(set, name, type, cards, sideboard)
    @set = set
    @name = name
    @type = type
    @cards = cards
    @sideboard = sideboard
    @slug = @name.downcase.gsub("'s", "s").gsub(/[^a-z0-9s]+/, "-")
  end

  def number_of_mainboard_cards
    @cards.map(&:first).inject(0, &:+)
  end

  def number_of_sideboard_cards
    @sideboard.map(&:first).inject(0, &:+)
  end

  def number_of_total_cards
    number_of_mainboard_cards + number_of_sideboard_cards
  end

  def physical_cards
    [*@cards.map(&:last), *@sideboard.map(&:last)].uniq
  end

  def inspect
    "Deck<#{set.name} - #{@name} - #{@type}>"
  end

  def set_code
    @set.code
  end

  def to_s
    inspect
  end
end

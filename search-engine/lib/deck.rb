class Deck
  attr_reader :set, :name, :type, :card, :sideboard
  def initialize(set, name, type, cards, sideboard)
    @set = set
    @name = name
    @type = type
    @cards = cards
    @sideboard = sideboard
  end

  def number_of_cards
    @cards.map(&:first).inject(0, &:+)
  end

  def number_of_sideboard_cards
    @sideboard.map(&:first).inject(0, &:+)
  end
end

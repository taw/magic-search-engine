# One place a card can be got from - a preconstructed deck, a booster, or a
# sealed product that names the card in its own contents - and which finishes
# it comes in there.
#
# Products that only reach the card through a deck, a booster or a subproduct
# are deliberately not among them. Every booster box, case and display in a set
# reaches every card in it, so listing them says nothing a card page reader
# does not already know, and there are 1.28M such (card, product) pairs against
# 1013 direct ones. `bin/report_card_sources` computes the full transitive
# closure for when that question is actually being asked.
class CardAvailability
  attr_reader :source, :finishes

  # Finishes arrive in whatever order the decklist or the sheets happened to be
  # in, and with duplicates - a booster with a foil sheet and an etched sheet
  # reaches the card twice.
  def initialize(source, finishes)
    @source = source
    @finishes = PhysicalCard::FINISHES & finishes
  end

  def deck?
    @source.is_a?(PreconDeck)
  end

  def booster?
    @source.is_a?(Pack)
  end

  def product?
    @source.is_a?(Product)
  end

  # A card that only comes nonfoil is just a card, so it gets no label at all.
  # Anything else names every finish, including the nonfoil one, as "foil"
  # next to a booster would otherwise read as "only foil".
  def finish_label
    return nil if @finishes == [:nonfoil]
    case @finishes.size
    when 1
      @finishes[0].to_s
    when 2
      @finishes.join(" and ")
    else
      "#{@finishes[0..-2].join(", ")}, and #{@finishes[-1]}"
    end
  end

  def ==(other)
    other.is_a?(CardAvailability) and source.equal?(other.source) and finishes == other.finishes
  end

  def inspect
    "CardAvailability[#{@source.name}; #{@finishes.join(", ")}]"
  end
end

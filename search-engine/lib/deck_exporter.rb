# Turns a deck into text some other program can read.
#
# Takes any Deck - a precon we ship, or a decklist someone pasted into
# /deck/visualize - so the only thing the subclasses know about metadata is
# what Deck promises: a name, a url, a date, and a display blurb, any of which
# can be missing. Which collector numbers, card names and set codes each format
# wants was checked against those programs' own source.
#
# Subclasses implement #generate, and collect a warning whenever the format
# cannot carry something the deck has.
class DeckExporter
  # The order every export writes sections in, which is the order
  # PreconDeck#to_text has always used. Anything else a deck carries follows,
  # in the deck's own order.
  SECTION_ORDER = ["Commander", "Main Deck", "Sideboard", "Planar Deck", "Display Commander", "Scheme Deck"]

  # Sections which are cards, but not sideboard cards, and which no format
  # except our own has a place for
  EXTRA_SECTIONS = ["Planar Deck", "Scheme Deck"]

  # An oversized copy of a card the deck already has, so the only sane thing
  # any other format can do with it is leave it out
  DISPLAY_SECTION = "Display Commander"

  attr_reader :deck

  def initialize(deck)
    @deck = deck
    @warnings = []
    @generated = false
  end

  def text
    generate! unless @generated
    @text
  end

  def warnings
    generate! unless @generated
    @warnings
  end

  def to_s
    text
  end

  def filename
    "#{deck.name || "deck"}.#{self.class.extension}"
  end

  class << self
    # Every format the export dialog offers, in the order it offers them
    def all
      @all ||= []
    end

    def [](code)
      all.find{|exporter| exporter.code == code }
    end

    def codes
      all.map(&:code)
    end

    # Subclasses declare themselves with `format "arena", "Arena style", "txt"`,
    # which is also what puts them in the list above
    def format(code, name, extension)
      @code, @name, @extension = code, name, extension
      DeckExporter.all << self
    end

    attr_reader :code, :name, :extension
  end

  private

  def generate!
    @text = generate
    @generated = true
  end

  # [name, cards] for every section which has any cards, in export order
  def sections
    names = SECTION_ORDER | deck.section_names
    names.filter_map do |name|
      cards = deck.section(name)
      [name, cards] unless cards.empty?
    end
  end

  # What a format with only two zones can do with our sections: commander and
  # anything exotic joins the sideboard, the display commander is dropped.
  # Everything here is a warning, because it is not what the deck says.
  def main_and_sideboard
    main = deck.section("Main Deck")
    sideboard = deck.section("Sideboard").dup
    unless deck.section("Commander").empty?
      warn_about "Commander goes to the sideboard, as the format has no place to mark it"
      sideboard = deck.section("Commander") + sideboard
    end
    EXTRA_SECTIONS.each do |name|
      next if deck.section(name).empty?
      warn_about "#{name} cards go to the sideboard, as the format has no #{name.downcase}"
      sideboard += deck.section(name)
    end
    unless deck.section(DISPLAY_SECTION).empty?
      warn_about "#{DISPLAY_SECTION} left out, as it is an oversized copy of a card the deck already has"
    end
    [main, sideboard]
  end

  # What a format with a commander zone can do with our sections: only the
  # exotic ones have nowhere to go, and the display commander is still dropped.
  def commander_main_and_sideboard
    sideboard = deck.section("Sideboard").dup
    EXTRA_SECTIONS.each do |name|
      next if deck.section(name).empty?
      warn_about "#{name} cards go to the sideboard, as the format has no #{name.downcase}"
      sideboard += deck.section(name)
    end
    unless deck.section(DISPLAY_SECTION).empty?
      warn_about "#{DISPLAY_SECTION} left out, as it is an oversized copy of a card the deck already has"
    end
    [deck.section("Commander"), deck.section("Main Deck"), sideboard]
  end

  # Two cards a format writes identically have to come out as one line: to
  # anything which cannot say which finish a card is, 4 foil and 4 nonfoil
  # Islands of one printing are 8 Islands, and to anything which drops the
  # printing entirely they are 8 Islands even across sets. The first card of a
  # group stands for all of them, so the line is written from a real card.
  def merge_cards(cards)
    merged = {}
    cards.each do |count, card|
      entry = (merged[merge_key(card)] ||= [0, card])
      entry[0] += count
    end
    merged.values
  end

  # Our own format writes every distinction we know about, so nothing merges
  def merge_key(card)
    card
  end

  # For formats which name a printing but not its finish. A card we know
  # nothing about has only its name to be told apart by.
  def printing_key(card)
    known?(card) ? [card.set_code, card_number(card)] : card.name
  end

  # The front list: "Fire // Ice" for a split card, but "Delver of Secrets" for
  # a transform card. Every format except our own wants this one.
  def card_name(card)
    card.name
  end

  # Programs disagree about which layouts are one card with a two-part name.
  # We are the most generous: our front list joins every part printed on the
  # front, so an adventure and a flip card both come out with two names. A
  # destination which keeps fewer layouts joined has to say which, and gets the
  # main front's name alone for the rest - and a card database looks a name up
  # exactly, so this is not cosmetic.
  def joined_name(card, layouts, separator=" // ")
    return card.name unless known?(card)
    return card.main_front.name unless layouts.include?(card.main_front.layout)
    card.name.gsub(" // ", separator)
  end

  # Scryfall numbers a physical card, we number each face. Everything built on
  # Scryfall data rejects our numbers, so this is what all the new formats use.
  def card_number(card)
    card.physical_card_number
  end

  def known?(card)
    card.is_a?(PhysicalCard)
  end

  # A pasted decklist can name a card we know nothing about, and then a name is
  # all any format gets to print
  def warn_about_unknown_cards
    unknown = deck.all_cards.reject{|_, card| known?(card) }
    return if unknown.empty?
    warn_about "Not in our database, so exported without printing information: #{card_list(unknown.map{|_, card| card.name })}"
  end

  # Formats which keep the printing but have nowhere to say which finish it is
  def warn_about_dropped_finishes
    finishes = deck.physical_cards.grep(PhysicalCard).select{|card| card.foil or card.etched }
    return if finishes.empty?
    warn_about "Exported as normal cards, as the format cannot mark a finish: #{card_list(finishes.map(&:name))}"
  end

  # Warnings name the cards they are about, because "3 cards were left out" is
  # not something anyone can act on. A pasted list can be all unknown names,
  # so the list stops after a few.
  def card_list(names, limit=10)
    names = names.uniq.sort
    return names.join(", ") if names.size <= limit
    names.first(limit).join(", ") + ", and #{names.size - limit} more"
  end

  def warn_about(message)
    @warnings << message unless @warnings.include?(message)
  end
end

# Listed rather than globbed, because this is the order the dialog offers them
# in, and because the two legacy formats are one class and its subclass
%W[text names arena arena_compatible csv mtgo xmage cockatrice mythichub].each do |format|
  require_relative "deck_exporter/#{format}"
end

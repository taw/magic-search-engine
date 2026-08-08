class DeckParser
  # Sections mtg.wtf decks can have, and the headers other tools write for them.
  # A header has to be the whole line (or the part before the colon), so these
  # cannot eat a card name.
  SECTION_HEADERS = {
    "Main Deck" => ["main deck", "maindeck", "mainboard", "main", "deck", "decklist"],
    "Commander" => ["commander", "commanders"],
    "Sideboard" => ["sideboard", "side board", "sb"],
    "Planar Deck" => ["planar deck", "planes"],
    "Scheme Deck" => ["scheme deck", "schemes"],
    "Display Commander" => ["display commander"],
    # Sections that only exist while parsing, see #finish_scratch_sections!
    "Companion" => ["companion"],
    "About" => ["about"],
  }
  SCRATCH_SECTIONS = ["Companion", "About"]
  SECTIONS = SECTION_HEADERS.keys - SCRATCH_SECTIONS
  SECTION_BY_HEADER = SECTION_HEADERS.flat_map{|section, headers| headers.map{|header| [header, section]} }.to_h

  # Arena-style printing, like "Lion Sash (NEO) 232", or The List's
  # "Amulet of Vigor (PLST) WWK-121". Cockatrice and TappedOut leave out the
  # number. Only used for names we don't know - "Unquenchable Fury (TBTH)" is
  # a card in one of our own decks, not Unquenchable Fury from tbth.
  ARENA_PRINTING = /\A(.*?)\s*\((\w{2,6})\)(?:\s+(\d+[a-z★†]?|[a-z0-9]+-\d+[a-z★†]?))?\z/i

  # Archidekt exports cards from sets Arena doesn't have as "Think Twice () 92",
  # with empty parens where the set code would be. The number means nothing
  # without a set, so all we get out of such a line is the name.
  ARENA_PRINTING_NO_SET = /\A(.*?)\s*\(\)(?:\s+(?:\d+[a-z★†]?|[a-z0-9]+-\d+[a-z★†]?))?\z/i

  # Arena-style finish markers: *F* foil, *E* etched, plus ones we have no use
  # for like TappedOut's *CMDR*
  MARKER = /\s*\*(\w+)\*/

  # Moxfield tags: "#TargetedDisruption", "#!CollectionTag"
  TAGS = /\s+#!?\S+/

  # For testing only:
  attr_reader :lines, :sections

  attr_reader :section_cards

  def initialize(db, text)
    @db = db
    @text = text
    @lines = text.sub(/\A\s+/, "").sub(/\s+\z/, "").lines.map(&:chomp).map(&:strip)
    preparse
    @section_cards = @sections.transform_values{|card_list| resolve_card_list(card_list) }
  end

  # This method is really messy, but is has decent test coverage
  def preparse
    @sections = SECTION_HEADERS.keys.to_h{|section| [section, []] }
    current = @sections["Main Deck"]
    @lines.each do |line|
      foil = nil
      etched = nil
      number = nil
      next if line =~ /\A\s*[#\/]/
      # In some decklist formats empty line separates sideboard
      next if line.empty?
      header = DeckParser.section_header(line)
      if header
        current = @sections[header]
        next
      end
      prefix, rest = DeckParser.section_prefixed(line)
      if prefix
        target, line = @sections[prefix], rest
      else
        target = current
      end
      if line =~ /\A(\d+)x?\s*(.*)/
        num, name = $1.to_i, $2
      else
        num, name = 1, line.dup
      end
      while name.sub!(/\s*\[(.*?)\]/, "")
        tag = $1
        case tag
        when /\Afoil\z/i
          foil = true
        when /\Aetched\z/i
          etched = true
        when %r[\A(.*)[/:](.*)\z]
          set_code = $1
          number = $2
        else
          set_code = tag
        end
      end
      while name.sub!(MARKER, "")
        case $1
        when /\Af\z/i
          foil = true
        when /\Ae\z/i
          etched = true
        end
      end
      name.gsub!(TAGS, "")
      # This wins over a bracket, because a line with both is Archidekt, where
      # the bracket is a user-defined category and only the parens are a set
      if name =~ ARENA_PRINTING and !known_card?(name)
        name, set_code = $1, $2
        number = $3 if $3
      elsif name =~ ARENA_PRINTING_NO_SET and !known_card?(name)
        # Empty parens win over a bracket the same way a set code would, so an
        # Archidekt category like "[Mana Advantage]" doesn't become a set
        name, set_code, number = $1, nil, nil
      end
      # Nothing but a count, like the "15" of a "Sideboard: 15" header
      next if name.empty?
      target << {name: name, count: num, set_code: set_code, number: number, foil: foil, etched: etched}.compact
    end
    finish_scratch_sections!
    commander_detection_heuristic!
  end

  def main
    @sections["Main Deck"]
  end

  def side
    @sections["Sideboard"]
  end

  def commander
    @sections["Commander"]
  end

  def main_cards
    @section_cards["Main Deck"]
  end

  def sideboard_cards
    @section_cards["Sideboard"]
  end

  def commander_cards
    @section_cards["Commander"]
  end

  def deck
    Deck.new(@section_cards)
  end

  # Section header on a line of its own, like "Sideboard", "sideboard:",
  # "Planar Deck", or "Sideboard (15)"
  def self.section_header(line)
    return unless line =~ /\A([a-z][a-z ]*?)\s*(?::\s*\d*|\(\s*\d+\s*\))?\z/i
    SECTION_BY_HEADER[normalize_header($1)]
  end

  # Section name used as a prefix on every card in it, like "SB: Taiga"
  # or "COMMANDER: 1 The Fourth Doctor"
  def self.section_prefixed(line)
    return unless line =~ /\A([a-z][a-z ]*?)\s*:\s*(\S.*)\z/i
    section = SECTION_BY_HEADER[normalize_header($1)]
    [section, $2] if section
  end

  def self.normalize_header(header)
    header.downcase.split.join(" ")
  end

  private

  # A companion is a sideboard card, and Arena lists it in both sections,
  # so only take it if the sideboard doesn't have it already. Nothing in the
  # About section is about cards.
  def finish_scratch_sections!
    @sections["Companion"].each do |card|
      next if @sections["Sideboard"].any?{|other| normalize_name(other[:name]) == normalize_name(card[:name]) }
      @sections["Sideboard"] << card
    end
    @sections = @sections.slice(*SECTIONS)
  end

  def known_card?(name)
    !!@db.cards[normalize_name(name)]
  end

  def resolve_card_list(card_list)
    card_list = card_list.map do |card_description|
      [card_description[:count], resolve_card(card_description)]
    end
    card_list = card_list.select(&:last)
    card_list.group_by(&:last).map{|c, num| [num.map(&:first).sum, c] }
  end

  def resolve_card(card_description)
    name = card_description[:name]
    set_code = card_description[:set_code]
    number = card_description[:number]
    foil = !!card_description[:foil]
    etched = !!card_description[:etched]
    card = @db.cards[normalize_name(name)]
    if card
      printings = card.printings
      best_printing = select_best_printing(printings, set_code, number)
      return PhysicalCard.for(best_printing, foil, etched)
    end
    parts = name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    if parts.size > 1
      card = @db.cards[parts[0]]
      if card
        printings = card.printings
        best_printing = select_best_printing(printings, set_code, number)
        return PhysicalCard.for(best_printing, foil, etched)
      end
    end

    # Not tracking foils for that
    return UnknownCard.new(name)
  end

  def select_best_printing(printings, set_code, number)
    if set_code
      sets = @db.resolve_editions(set_code)
      printings_in_set = printings.select{|c| sets.include?(c.set) }
      printings = printings_in_set unless printings_in_set.empty?
    end
    if number
      printings_with_number = printings.select{|c| c.number.downcase == number.downcase }
      if printings_with_number.empty?
        # Deal with 123a / 123b split cards etc.
        printings_with_number = printings.select{|c| c.number_i == number.to_i }
      end
      printings = printings_with_number unless printings_with_number.empty?
    end
    printings.min_by(&:default_sort_index)
  end

  # These method seem to occur in every single class out there
  def normalize_text(text)
    text.downcase.normalize_accents.strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end

  # Many deck formats do not have commander slot and use sideboard for that
  def commander_detection_heuristic!
    return unless commander.empty?
    return if side.empty?
    main_size = main.map{|x| x[:count] }.sum
    side_size = side.map{|x| x[:count] }.sum
    total_size = main_size + side_size
    return unless total_size == 60 or total_size == 100
    if side_size == 1 or side_size == 2
      @sections["Commander"], @sections["Sideboard"] = @sections["Sideboard"], @sections["Commander"]
    end
  end
end

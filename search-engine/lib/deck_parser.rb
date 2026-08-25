require "csv"

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

  # Decoration around a header, like MythicHub's "== MAINBOARD ==". The same
  # run of characters has to close it as opened it, so a card name cannot be
  # mistaken for one.
  DECORATED_HEADER = /\A(=+|-+|\*+)\s*(.*?)\s*\1\z/

  # A collector number the way printings write them: "232", "51a", "115★",
  # The List's "WWK-121", and the World Championship decks' "jt128", where the
  # player's initials are part of the number. Only the digit is required, which
  # is what stops this from reading an ordinary word as a number.
  NUMBER = /[a-z0-9★†_-]*\d[a-z0-9★†_-]*/i

  # Arena-style printing, like "Lion Sash (NEO) 232", or The List's
  # "Amulet of Vigor (PLST) WWK-121". Cockatrice and TappedOut leave out the
  # number. Only used for names we don't know - "Unquenchable Fury (TBTH)" is
  # a card in one of our own decks, not Unquenchable Fury from tbth.
  ARENA_PRINTING = /\A(.*?)\s*\((\w{2,6})\)(?:\s+(#{NUMBER}))?\z/i

  # Archidekt exports cards from sets Arena doesn't have as "Think Twice () 92",
  # with empty parens where the set code would be. The number means nothing
  # without a set, so all we get out of such a line is the name.
  ARENA_PRINTING_NO_SET = /\A(.*?)\s*\(\)(?:\s+(?:#{NUMBER}))?\z/i

  # MythicHub writes the collector number after the set, as "[ISD] #51" or
  # "[PLST] #WWK-121". Moxfield's tags start with a # too, so a number is only
  # read from a line which named a set in brackets and no number with it.
  HASH_NUMBER = /\s+#(#{NUMBER})\z/

  # MythicHub spells the finish out at the end of the line instead of marking
  # it. There is a card called Foil, so this needs something in front of it.
  FINISH_WORD = /\S\K\s+(foil|etched)\z/i

  # Arena-style finish markers: *F* foil, *E* etched, plus ones we have no use
  # for like TappedOut's *CMDR*
  MARKER = /\s*\*(\w+)\*/

  # Moxfield tags: "#TargetedDisruption", "#!CollectionTag"
  TAGS = /\s+#!?\S+/

  # The two formats which are XML instead of lines. UserDeckPreprocessor already
  # turns either into a decklist for an uploaded file, so this is the same file
  # pasted into the box instead of chosen with the button.
  XML_DECK = /\A\s*<(\?xml|cockatrice_deck|Deck[\s>])/

  # XMage's own metadata: NAME: and AUTHOR: describe the deck, the LAYOUT lines
  # describe how its deck editor arranged the cards. None of them are cards.
  METADATA_LINE = /\A(name|author|layout main|layout sideboard):/i

  # Every collection site exports a variant of one table, and ours has a column
  # for the section a card came from as well. Columns we have no use for, like
  # Moxfield's "Tradelist Count", are ignored rather than rejected.
  CSV_COLUMNS = {
    "section" => :section,
    "category" => :section,
    "count" => :count,
    "quantity" => :count,
    "qty" => :count,
    "name" => :name,
    "card name" => :name,
    "card" => :name,
    "set code" => :set_code,
    "edition code" => :set_code,
    "set" => :set_code,
    "edition" => :set_code,
    "collector number" => :number,
    "card number" => :number,
    "number" => :number,
    "finish" => :finish,
    "foil" => :finish,
    "printing" => :finish,
  }

  # For testing only:
  attr_reader :lines, :sections

  attr_reader :section_cards

  def initialize(db, text)
    @db = db
    text = UserDeckPreprocessor.new(text.dup).text.to_s if text =~ XML_DECK
    @text = text
    @lines = text.sub(/\A\s+/, "").sub(/\s+\z/, "").lines.map(&:chomp).map(&:strip)
    preparse
    @section_cards = @sections.transform_values{|card_list| resolve_card_list(card_list) }
  end

  def preparse
    @sections = SECTION_HEADERS.keys.to_h{|section| [section, []] }
    rows = csv_rows
    rows ? parse_csv(rows) : parse_lines
    finish_scratch_sections!
    commander_detection_heuristic!
  end

  # This method is really messy, but it has decent test coverage
  def parse_lines
    current = @sections["Main Deck"]
    @lines.each do |line|
      foil = nil
      etched = nil
      number = nil
      next if line =~ /\A\s*[#\/]/
      # In some decklist formats empty line separates sideboard
      next if line.empty?
      next if line =~ METADATA_LINE
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
      # XMage puts its bracket before the name, so taking one off can leave the
      # name with a space in front of it
      name.strip!
      while name.sub!(MARKER, "")
        case $1
        when /\Af\z/i
          foil = true
        when /\Ae\z/i
          etched = true
        end
      end
      # The finish comes after the number, so it has to come off first
      if name.sub!(FINISH_WORD, "")
        $1.downcase == "etched" ? etched = true : foil = true
      end
      number = $1 if set_code and number.nil? and name.sub!(HASH_NUMBER, "")
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
  end

  # One row per card, with the section in a column of its own, so none of the
  # line format's guessing applies here
  def parse_csv(rows)
    columns = csv_columns(rows.first)
    rows.drop(1).each do |row|
      fields = {}
      columns.each_with_index do |column, i|
        value = row[i].to_s.strip
        fields[column] = value if column and !value.empty?
      end
      next unless fields[:name]
      section = SECTION_BY_HEADER[DeckParser.normalize_header(fields[:section].to_s)] || "Main Deck"
      @sections[section] << {
        name: fields[:name],
        count: fields[:count] ? fields[:count].to_i : 1,
        set_code: fields[:set_code],
        number: fields[:number],
        foil: (true if fields[:finish] =~ /\Afoil\z/i),
        etched: (true if fields[:finish] =~ /\Aetched\z/i),
      }.compact
    end
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
  # "Planar Deck", "Sideboard (15)", or MythicHub's "== SIDEBOARD =="
  def self.section_header(line)
    line = $2 if line =~ DECORATED_HEADER
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

  # A decklist has commas in it - "Bruna, the Fading Light" is not two columns -
  # so this is a table only when the first row is a header naming both a count
  # and a name. That row is read on its own, so a decklist costs one line rather
  # than a parse of the whole file.
  def csv_rows
    return nil unless @lines.first.to_s.include?(",")
    columns = csv_columns(CSV.parse_line(@lines.first) || [])
    return nil unless columns.include?(:name) and columns.include?(:count)
    CSV.parse(@lines.join("\n"))
  rescue CSV::MalformedCSVError
    nil
  end

  def csv_columns(header)
    header.map{|field| CSV_COLUMNS[DeckParser.normalize_header(field.to_s)] }
  end

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
    foil = card_description[:foil]
    etched = card_description[:etched]
    card = @db.cards[normalize_name(name)]
    if card
      printings = card.printings
      best_printing = select_best_printing(printings, set_code, number)
      return PhysicalCard.for(best_printing, foil: foil, etched: etched)
    end
    parts = name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    if parts.size > 1
      card = @db.cards[parts[0]]
      if card
        printings = card.printings
        best_printing = select_best_printing(printings, set_code, number)
        return PhysicalCard.for(best_printing, foil: foil, etched: etched)
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
      number = number.downcase
      printings_with_number = printings.select{|c| c.number.downcase == number }
      if printings_with_number.empty?
        # Every format but our own numbers the physical card, so "51" has to
        # find the "51a" and "51b" we number its faces
        printings_with_number = printings.select{|c| c.number.downcase.sub(/[a-z]\z/, "") == number }
      end
      if printings_with_number.empty?
        # Deal with 123a / 123b split cards etc.
        printings_with_number = printings.select{|c| c.number_i == number.to_i }
      end
      printings = printings_with_number unless printings_with_number.empty?
    end
    printings.min_by(&:default_sort_index)
  end

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

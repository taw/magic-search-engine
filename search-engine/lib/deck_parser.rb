class DeckParser
  # For testing only:
  attr_reader :lines, :main, :side, :commander

  attr_reader :main_cards, :sideboard_cards, :commander_cards

  def initialize(db, text)
    @db = db
    @text = text
    @lines = text.sub(/\A\s+/, "").sub(/\s+\z/, "").lines.map(&:chomp).map(&:strip)
    preparse
    @main_cards = resolve_card_list(@main)
    @sideboard_cards = resolve_card_list(@side)
    @commander_cards = resolve_card_list(@commander)
  end

  # This method is really messy, but is has decent test coverage
  def preparse
    @main = []
    @side = []
    @commander = []
    current = @main
    @lines.each do |line|
      foil = nil
      set = nil
      number = nil
      next if line =~ /\A\s*[#\/]/
      # In some decklist formats empty line separates sideboard
      next if line.empty?
      if line =~ /\Asideboard:?\z/i
        current = @side
        next
      end
      if line =~ /\ASB:\s*(.*)/
        target, line = @side, $1
      elsif line =~ /\ACOMMANDER:\s*(.*)/
        target, line = @commander, $1
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
          set_code = $1
          number = $2
        else
          set_code = tag
        end
      end
      target << {name: name, count: num, set_code: set_code, number: number, foil: foil}.compact
    end
    commander_detection_heuristic!
  end

  def deck
    Deck.new(@main_cards, @sideboard_cards, @commander_cards)
  end

  private

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
    card = @db.cards[normalize_name(name)]
    if card
      printings = card.printings
      best_printing = select_best_printing(printings, set_code, number)
      return PhysicalCard.for(best_printing, foil)
    end
    parts = name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    if parts.size > 1
      card = @db.cards[parts[0]]
      if card
        printings = card.printings
        best_printing = select_best_printing(printings, set_code, number)
        return PhysicalCard.for(best_printing, foil)
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
    return unless @commander.empty?
    return if @side.empty?
    main_size = @main.map{|x| x[:count] }.sum
    side_size = @side.map{|x| x[:count] }.sum
    total_size = main_size + side_size
    return unless total_size == 60 or total_size == 100
    if side_size == 1 or side_size == 2
      @commander, @side = @side, @commander
    end
  end
end

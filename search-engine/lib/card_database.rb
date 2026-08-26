require "json"
require "nokogiri"
require "pathname"
require "set"
require "yaml"
require_relative "ability_word"
require_relative "artist"
require_relative "card_availability"
require_relative "card_printing"
require_relative "card_set"
require_relative "card_sheet_factory"
require_relative "card_sheet"
require_relative "card"
require_relative "color_balanced_card_sheet"
require_relative "card_sheet_with_duplicates"
require_relative "fixed_card_list"
require_relative "fixed_card_sheet"
require_relative "limited_format"
require_relative "mtgo_ids"
require_relative "color"
require_relative "deck_database"
require_relative "deck_exporter"
require_relative "deck_parser"
require_relative "deck"
require_relative "pack_factory"
require_relative "pack"
require_relative "physical_card"
require_relative "precon_deck"
require_relative "product"
require_relative "product_variable_contents"
require_relative "query"
require_relative "random_boosters"
require_relative "scryfall_ids"
require_relative "sealed"
require_relative "sealed_pool"
require_relative "spelling_suggestions"
require_relative "unknown_card"
require_relative "user_deck_preprocessor"
require_relative "weighted_pack"

class String
  LIGATURES = {"Æ" => "Ae", "æ" => "ae", "Œ" => "Oe", "œ" => "oe"}.freeze
  LIGATURES_RX = /[ÆæŒœ]/

  # This is a much longer list than just what's on cards as:
  # * it's also artist names
  # * everything is both upper and lower case,
  #   even if only one case is actually in print
  #   (except Turkish ı)
  ACCENTS_FROM = "ÀÁÂÄẤÃĀàáâäãấãāĆČÇćčçÈËÊÉĖèéêëēėǵÍÏĪÎíïīîıŁłÑñńÓÖŌØõöóøōÛÜÚúûüŠšÝýŻżˣ’\u2212"
  ACCENTS_TO   = "AAAAAAAaaaaaaaaCCCcccEEEEEeeeeeegIIIIiiiiiLlNnnOOOOoooooUUUuuuSsYyZzx'-"

  # Almost everything that comes through here is plain ASCII, and comes back out
  # of gsub and tr byte for byte identical, having allocated two throwaway copies
  # on the way. Those copies were most of the garbage that loading the index
  # produced, and peak garbage sets the heap size the process then holds on to
  # for the rest of its life, so it's worth a scan to learn there's nothing to do.
  NORMALIZE_RX = Regexp.new("[" + Regexp.escape(LIGATURES.keys.join + ACCENTS_FROM) + "]")

  def normalize_accents
    return -self unless NORMALIZE_RX.match?(self)
    result = gsub(LIGATURES_RX, LIGATURES).tr(ACCENTS_FROM, ACCENTS_TO)
    result = self if result == self # Memory saving trick
    -result
  end
end

class CardDatabase
  attr_reader :sets, :cards, :blocks, :artists, :cards_in_precons, :products
  attr_reader :limited_formats

  INDEX_ROOT = Pathname(__dir__) + "../../index"
  SETS_PATH = INDEX_ROOT + "sets.json"
  CARDS_PATH = INDEX_ROOT + "cards.jsonl"
  BOOSTER_INDEX_PATH = INDEX_ROOT + "booster_index.json"
  PRODUCTS_PATH = INDEX_ROOT + "products.json"
  LIMITED_FORMATS_PATH = INDEX_ROOT + "limited_formats.json"

  # Arena has no code for an individual Alchemy set. It files all of them under
  # one pseudo-set per Arena year, and that is the code its own decklists carry
  # ("1 Big Spender (Y22) 10"), so it has to resolve to something. One
  # alternative_code per set cannot express many-to-one, so it lives here.
  #
  # No rule reproduces the grouping. It is not the calendar year - Alchemy:
  # Innistrad is Y22 and came out in December 2021 - and any date cut that keeps
  # Alchemy: Bloomburrow (2024-08-20) and Alchemy: Edge of Eternities
  # (2025-08-19) both in Y25 is one day wide. It is nearly the Alchemy rotation
  # calendar, and 16 of these 17 sets do fall in the rotation window they belong
  # to, but Edge of Eternities rotates on the paper set's release and its
  # Alchemy set follows three weeks later, so that one lands a window late.
  #
  # The table is therefore read out of Arena's own card data rather than worked
  # out, and set_codes_spec pins what does hold: the year is the calendar year
  # of the last Alchemy set in it, years do not interleave, and every Alchemy
  # set is listed exactly once - so a new one fails the spec until it is added.
  ARENA_ALCHEMY_YEARS = {
    "y22" => %W[ymid yneo ysnc],
    "y23" => %W[ydmu ybro yone],
    "y24" => %W[ywoe ylci ymkm yotj],
    "y25" => %W[yblb ydsk ydft ytdm yeoe],
    "y26" => %W[yecl ysos],
  }.freeze

  def initialize
    @sets = {}
    @blocks = {}
    @cards = {}
    @artists = {}
    yield(self)
  end

  def search(query)
    query = Query.new(query) unless query.is_a?(Query)
    query.search(self)
  end

  def each_printing
    @cards.each do |card_name, card|
      card.printings.each do |printing|
        yield printing
      end
    end
  end

  def printings
    @printings ||= enum_for(:each_printing).to_a
  end

  def decks
    @decks ||= @sets.values.flat_map(&:decks)
  end

  # Everywhere a card can be got: preconstructed decks, boosters, and sealed
  # products that name it in their own contents, each with the finishes it
  # comes in there. See CardAvailability for what is left out and why.
  #
  # Decks and boosters are scanned rather than indexed: the reverse map is
  # 330k (card, source) pairs and the server is short of memory, while both
  # sides of the scan are already loaded - decks for the deck pages, sheets
  # because initialize_booster_flag has already walked every one of them. Only
  # products are indexed, and there are a thousand of those references, not
  # 330k. Half a millisecond a card, which is less than the deck-only list this
  # replaced took.
  def availability(card_printing)
    main_front = card_printing.main_front
    availability_in_decks(main_front) +
      availability_in_boosters(main_front) +
      availability_in_products(main_front)
  end

  # The same thing for every printing of a card at once, as printing =>
  # availability, in `card.printings` order and including the printings that
  # have none. Calling `availability` in a loop is pathological for a card with
  # many printings, since each call rescans the decks and the booster sheets
  # from the start: Forest has 943 printings and costs 406ms that way against
  # 29ms for one pass collecting all of them (dev machine, loaded database).
  #
  # One pass is not free either - it is two full scans - so the per-printing
  # prefilters are kept, widened to the sets the card is in. A card in one set
  # skips almost every deck and booster here, the same way it does above, and
  # only a card printed everywhere pays for the whole walk.
  def availability_of_all_printings(card)
    printings_by_front = {}.compare_by_identity
    card.printings.each{|printing| printings_by_front[printing.main_front] = printing }
    result = card.printings.to_h{|printing| [printing, []] }

    availability_in_decks_of_card(printings_by_front, result)
    availability_in_boosters_of_card(printings_by_front, result)
    printings_by_front.each do |main_front, printing|
      result[printing].concat(availability_in_products(main_front))
    end
    result
  end

  # The other side of the same question: which printings nothing reaches, which
  # is what `is:productless` asks. With no finish that means nothing reaches
  # them at all, in any finish; with one it means the card was printed in that
  # finish and nothing reaches it in that finish, whatever the other finishes
  # do - `is:productlessfoil` and friends. Unlike `is:foil`, that foil is the
  # plain foil printing alone, so an etched card in an etched booster answers
  # `is:productlessetched` and nothing else.
  #
  # It is the same three scans as `availability`, but without the per-card
  # prefilters, since every card is being asked about at once: one walk of the
  # decks, the sheets and the products, 30ms on a loaded database (dev machine).
  # What it finds is deliberately not memoized - it is 98k printings' worth of
  # map, the server is short of memory, and a query asks this once.
  def productless_printings(candidates=printings, finish: nil)
    available = Hash.new(0).compare_by_identity

    decks.each do |deck|
      deck.each_card{|_count, physical_card| available[physical_card.main_front] |= IndexFormat::FINISH_BITS[physical_card.finish] }
    end

    # One sheet belongs to every booster that draws from it, so walk each once
    seen_sheets = {}.compare_by_identity
    unique_supported_booster_types.each_value do |booster|
      booster.each_sheet do |sheet|
        next if seen_sheets[sheet]
        seen_sheets[sheet] = true
        sheet.cards.each{|physical_card| available[physical_card.main_front] |= IndexFormat::FINISH_BITS[physical_card.finish] }
      end
    end

    product_cards = {}
    products.each{|product| product_finishes(product.contents, product_cards) }
    product_cards.each do |main_front, finishes|
      finishes.each{|product_finish| available[main_front] |= IndexFormat::FINISH_BITS[product_finish] }
    end

    # A face is as available as the physical card it is on, so ask about the
    # main front rather than the printing itself
    return candidates.reject{|printing| available[printing.main_front] != 0 } unless finish
    wanted = IndexFormat::FINISH_BITS.fetch(finish)
    candidates.select do |printing|
      printing.has_finish?(finish) and (available[printing.main_front] & wanted) == 0
    end
  end

  def subset(sets)
    # puts "Loading subset: #{sets}"
    self.class.send(:new) do |db|
      db.send(:load_from_subset!, self, sets)
    end
  end

  # Excluding unsupported ones
  # It's a very slow method, so memoize, but better just make it fast
  def supported_booster_types
    unless @supported_booster_types
      @supported_booster_types = {}
      # Read once and held only for this loop. Every pack there is gets built
      # here, and nothing afterwards wants the data, only the packs.
      data_by_code = booster_data
      data_by_code.each_key do |booster_code|
        set_code, variant = booster_code.split("-", 2)
        # No such set is just no such pack. On a subset db most of the booster
        # index names sets that aren't loaded, so this is the normal case there,
        # not an error.
        set = resolve_edition(set_code) or next
        # resolve_edition matches on name and alternative code too, so on a
        # subset a code can land on some other set - "mma" finds Commander 2011
        # when that is the only set loaded. Take the data for the set's own
        # code, and if there is none, there is no booster.
        data = data_by_code[[set.code, variant].compact.join("-")] or next
        booster = PackFactory.new(self, set, variant, data).build_pack
        @supported_booster_types[booster.code] = booster
      end

      # Aliases
      @supported_booster_types.values.map(&:set_code).uniq.each do |set_code|
        next if @supported_booster_types[set_code]
        pack = @supported_booster_types["#{set_code}-draft"] || @supported_booster_types["#{set_code}-play"] || @supported_booster_types["#{set_code}-mtgo"]
        @supported_booster_types[set_code] = pack if pack
      end

      @supported_booster_types = @supported_booster_types.sort_by{|c,b| [-b.set.release_date.jd, c]}.to_h

      initialize_booster_flag
    end
    @supported_booster_types
  end

  # Whenever we list supported booster types, skip aliases
  def unique_supported_booster_types
    @unique_supported_booster_types ||= supported_booster_types.select{|code, booster| code == booster.code}
  end

  # Boosters a descriptor asks for. Usually one - a booster code like
  # "dgm-draft", or a set code like "dgm" for that set's default booster. A
  # pack the player got at random out of a few, like the allied guild booster
  # of the Dragon's Maze prerelease, is described as its alternatives joined
  # by "|".
  #
  # Descriptors come out of urls, so codes we have no booster for are skipped.
  def boosters_for_descriptor(descriptor)
    descriptor.to_s.split("|").filter_map{|code| supported_booster_types[code]}
  end

  def promo_types
    @promo_types ||= printings.flat_map(&:promo_types).uniq.compact.to_set
  end

  def frame_effects
    @frame_effects ||= printings.flat_map(&:frame_effects).uniq.compact.to_set
  end

  def set_types
    @set_types ||= sets.values.flat_map(&:types).uniq.compact.to_set
  end

  def token_set_code_to_set_code
    @token_set_code_to_set_code ||= sets.values.select(&:token_set_code).to_h{|set| [set.token_set_code, set.code] }
  end

  # Exclude Arena boosters
  # It will generally be XXX-play now
  def most_recent_booster_type
    # nil if the db has no boosters at all, which only happens on subsets
    @most_recent_booster_type ||= supported_booster_types.find{|k,v| !k.include?("-")}&.last&.code
  end

  def resolve_time(time)
    return nil unless time
    return time if time.is_a?(Date)
    sets = resolve_editions(time)
    case sets.size
    when 0
      nil
    when 1
      sets.first.release_date
    else
      # An Arena Alchemy year is several sets on purpose, and it starts when the
      # first of them comes out. Anything else resolving to several sets is an
      # ambiguous name, which has no time.
      raise "Can't parse time #{time}" unless ARENA_ALCHEMY_YEARS[time.downcase]
      sets.map(&:release_date).min
    end
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  #
  # Priority:
  # * exact code (official)
  # * Arena's Alchemy year code, which names several sets
  # * exact alternative code (mci)
  # * name exact match
  # * name substring match
  def resolve_editions(edition)
    edition = edition.downcase

    # Just don't bother with anything fancy if "e:foo" exists as a code
    if @sets[edition]
      return [@sets[edition]]
    end

    # Arena's Alchemy year, which is a code for several of our sets at once.
    # filter_map because subset databases have only some of them, or none.
    if ARENA_ALCHEMY_YEARS[edition]
      return ARENA_ALCHEMY_YEARS[edition].filter_map{|set_code| @sets[set_code] }
    end

    matching_alternative_code = []
    matching_name = []
    matching_name_part = []

    normalized_edition = normalize_set_name(edition)
    normalized_edition_alt = normalize_set_name_alt(edition)

    @sets.each do |set_code, set|
      normalized_set_name     = set.normalized_name
      normalized_set_name_alt = set.normalized_name_alt
      # Exact primary-code matches are already handled by the early return above,
      # so we only need to accumulate the lower-priority matches here.
      matching_alternative_code << set if set.alternative_code&.downcase == edition
      matching_name          << set if normalized_set_name == normalized_edition or normalized_set_name_alt == normalized_edition_alt
      matching_name_part     << set if normalized_set_name.include?(normalized_edition) or normalized_set_name_alt.include?(normalized_edition_alt)
    end

    [
      matching_alternative_code,
      matching_name,
      matching_name_part,
    ].find{|s| s.size > 0} || []
  end

  def resolve_deck_name(deck_name)
    deck_name = deck_name.strip

    # This is just for debugging, and UI is questionable for it
    return decks if deck_name == "*"

    if deck_name.include?("/")
      set_query, deck_query = deck_name.split("/", 2)
      sets = resolve_editions(set_query.strip)
      possible_decks = sets.flat_map(&:decks)
    else
      possible_decks = decks
      deck_query = deck_name
    end
    deck_query = deck_query
      .downcase
      .strip
      .gsub("'s", "")
      .delete(",")
      .normalize_accents

    return possible_decks if deck_query == "*"

    decks = possible_decks.select do |deck|
      deck.slug == deck_query
    end
    return decks unless decks.empty?

    decks = possible_decks.select do |deck|
      deck.normalized_name == deck_query
    end
    return decks unless decks.empty?

    normalized_query_words = deck_query.split

    possible_decks.select do |deck|
      normalized_words = deck.normalized_name.split
      normalized_query_words.all?{|qw| normalized_words.include?(qw)}
    end
  end

  def resolve_edition(edition)
    editions = resolve_editions(edition).to_a
    return editions[0] if editions.size <= 1
    raise "Ambiguous set name #{edition}, matches #{editions.size} sets"
  end

  class <<self
    private :new

    def load(root=INDEX_ROOT)
      new do |db|
        db.send(:load_from_index!, Pathname(root))
      end
    end
  end

  def suggest_spelling(word)
    spelling_suggestions.suggest(word)
  end

  def printing(set_code, number)
    set = @sets[set_code] or return
    set.printing_by_number[number]
  end

  def has_card_named?(name)
    c = cards[normalize_name(name)]
    !!c and c.name == name
  end

  # Without this every rspec failure and every pry prompt tries to print the
  # whole database
  def inspect
    "CardDatabase"
  end

  private

  # Shared by every sheet that turns out not to have the card, and by every
  # card no product names directly - which is nearly all of them
  NO_FINISHES = [].freeze
  NO_AVAILABILITY = [].freeze
  # Same, for the batch scans, which group the finishes by printing
  NO_SHEET_FINISHES = {}.freeze

  def availability_in_decks(main_front)
    set_code = main_front.set_code
    decks.filter_map do |deck|
      # A deck with no card from the set cannot have this one
      next unless deck.all_set_codes.include?(set_code)
      finishes = nil
      deck.each_card do |_count, physical_card|
        (finishes ||= []) << physical_card.finish if physical_card.main_front.equal?(main_front)
      end
      CardAvailability.new(deck, finishes) if finishes
    end
  end

  def availability_in_boosters(main_front)
    # Set by initialize_booster_flag out of these very sheets, so it is exact,
    # and it takes a third of all printings out of the scan entirely
    return [] unless main_front.in_boosters?
    set_code = main_front.set_code
    # One sheet belongs to every booster that draws from it - the whole of The
    # List is a single sheet shared by 24 of them - so scan each one once
    finishes_by_sheet = {}.compare_by_identity
    unique_supported_booster_types.each_value.filter_map do |booster|
      next unless booster.source_set_codes.include?(set_code)
      finishes = nil
      booster.each_sheet do |sheet|
        from_sheet = (finishes_by_sheet[sheet] ||= sheet_finishes(sheet, main_front))
        (finishes ||= []).concat(from_sheet) unless from_sheet.empty?
      end
      CardAvailability.new(booster, finishes) if finishes
    end
  end

  # The batch forms of the two scans above. They collect every printing of the
  # card in one walk instead of restarting for each one, so the hit is a
  # printing rather than a finish, and a source can reach several printings at
  # once - a deck with three different Forests is three separate lines.

  def availability_in_decks_of_card(printings_by_front, result)
    set_codes = printings_by_front.each_key.map(&:set_code).to_set
    decks.each do |deck|
      next unless deck.all_set_codes.intersect?(set_codes)
      finishes = nil
      deck.each_card do |_count, physical_card|
        printing = printings_by_front[physical_card.main_front] or next
        ((finishes ||= {}.compare_by_identity)[printing] ||= []) << physical_card.finish
      end
      next unless finishes
      finishes.each{|printing, printing_finishes| result[printing] << CardAvailability.new(deck, printing_finishes) }
    end
  end

  def availability_in_boosters_of_card(printings_by_front, result)
    # in_boosters? is exact, so the sets of the printings that are not in any
    # booster cannot widen the prefilter, and a card in no booster at all skips
    # the scan entirely
    set_codes = printings_by_front.each_key.select(&:in_boosters?).map(&:set_code).to_set
    return if set_codes.empty?
    finishes_by_sheet = {}.compare_by_identity
    unique_supported_booster_types.each_value do |booster|
      next unless booster.source_set_codes.any?{|set_code| set_codes.include?(set_code)}
      finishes = nil
      booster.each_sheet do |sheet|
        from_sheet = (finishes_by_sheet[sheet] ||= sheet_finishes_of_card(sheet, printings_by_front))
        next if from_sheet.empty?
        from_sheet.each do |printing, sheet_finishes|
          ((finishes ||= {}.compare_by_identity)[printing] ||= []).concat(sheet_finishes)
        end
      end
      next unless finishes
      finishes.each{|printing, printing_finishes| result[printing] << CardAvailability.new(booster, printing_finishes) }
    end
  end

  def sheet_finishes_of_card(sheet, printings_by_front)
    finishes = nil
    sheet.cards.each do |physical_card|
      printing = printings_by_front[physical_card.main_front] or next
      ((finishes ||= {}.compare_by_identity)[printing] ||= []) << physical_card.finish
    end
    finishes || NO_SHEET_FINISHES
  end

  def sheet_finishes(sheet, main_front)
    finishes = nil
    # Memoized by the sheet, and already built by initialize_booster_flag
    sheet.cards.each do |physical_card|
      (finishes ||= []) << physical_card.finish if physical_card.main_front.equal?(main_front)
    end
    finishes || NO_FINISHES
  end

  # The one side of this that is indexed rather than scanned. Products name
  # around a thousand cards directly between all 4136 of them, so the map is a
  # few hundred kilobytes, while walking every product's contents per card cost
  # more than the decks and the boosters together.
  def availability_in_products(main_front)
    unless @availability_in_products
      @availability_in_products = {}
      products.each do |product|
        cards = {}
        product_finishes(product.contents, cards)
        cards.each do |card_main_front, finishes|
          (@availability_in_products[card_main_front] ||= []) << CardAvailability.new(product, finishes)
        end
      end
    end
    @availability_in_products[main_front] || NO_AVAILABILITY
  end

  # Only contents naming a card itself. Decks, packs and subproducts are not
  # followed, which is the whole point - see CardAvailability.
  def product_finishes(contents, cards)
    contents.each do |_count, content|
      case content
      when PhysicalCard
        (cards[content.main_front] ||= []) << content.finish
      when ProductVariableContents
        # One of several subproducts, all of them possible, so all of them
        # count - the chances only matter to a simulator, and this is a "can
        # this card be in here" question
        content.options.each do |option|
          product_finishes(option[:subproduct], cards)
        end
      end
    end
  end

  # Read once each, by supported_booster_types, load_products! and
  # load_limited_formats!, and never looked at again - so nothing to memoize,
  # and nothing to hold on to afterwards
  def booster_data
    JSON.parse(BOOSTER_INDEX_PATH.read)
  end

  def products_data
    JSON.parse(PRODUCTS_PATH.read)
  end

  def limited_formats_data
    JSON.parse(LIMITED_FORMATS_PATH.read)
  end

  # CardPrinting#in_boosters? is only meaningful from this point
  def initialize_booster_flag
    @supported_booster_types.each_value do |booster|
      booster.cards.each do |physical_card|
        physical_card.parts.each do |card_printing|
          card_printing.in_boosters = true
        end
      end
    end
  end

  def normalize_set_name(name)
    normalize_text(name).downcase.gsub("'s", "s").split(/[^a-z0-9]+/).join(" ")
  end

  def normalize_set_name_alt(name)
    normalize_text(name).downcase.gsub("'s", "").split(/[^a-z0-9]+/).join(" ")
  end

  def load_from_subset!(db, set_codes)
    @blocks = db.blocks
    db.sets.each do |set_code, set|
      next unless set_codes.include?(set_code)
      @sets[set_code] = set
    end
    db.cards.each do |card_name, card|
      printings = card.printings.select do |printing|
        set_codes.include?(printing.set_code)
      end
      next if printings.empty?
      @cards[card_name] = card.dup
      @cards[card_name].printings = printings
    end
    # A subset shares its parent's sets and printings, so it can share the
    # boosters built out of them instead of building all 694 again for the
    # handful of sets it kept. Aliases come along, as they are keyed by set too.
    @supported_booster_types = db.supported_booster_types.select{|code, booster|
      set_codes.include?(booster.set_code)
    }
  end

  def load_from_index!(root)
    load_sets!(root + "sets.json")
    load_cards!(root + "cards.jsonl")
    resolve_references!
    setup_artists!
    setup_sort_indexes!
    # Needs `others` of every printing resolved, and number_sort_index to say
    # which of two fronts is the lower numbered one
    each_printing(&:calculate_main_front!)
    DeckDatabase.new(self).load!
    load_products!
    load_limited_formats!
    index_cards_in_precons!
  end

  def load_sets!(path)
    JSON.parse(path.read, freeze: true).each do |set_code, set_data|
      @sets[set_code] = CardSet.new(self, set_data)
      block_code = set_data["block_code"]
      next unless block_code

      # Make all of them point at the same object, so
      # blocks["zen"] = blocks["wwk"] = Set["zen", "wwk", "roe"]
      block = (@blocks[block_code] ||= Set[])
      @blocks[set_data["alternative_block_code"]] ||= block if set_data["alternative_block_code"]
      @blocks[normalize_name(set_data["block_name"])] ||= block
      @blocks[set_code] ||= block
      @blocks[normalize_name(set_data["name"])] ||= block
      block << set_code
    end
  end

  # One card per line, so each card's parsed JSON can be collected as soon as
  # the card is built. Parsing the whole index at once left a 190MB object
  # graph behind, and the heap it grew to is never given back to the OS.
  def load_cards!(path)
    path.each_line do |line|
      # Indexer removes most tokens, we allow only a very selected group of very special ones
      card_name, card_data = JSON.parse(line, freeze: true)
      normalized_name = card_name.downcase.normalize_accents
      card = @cards[normalized_name] = Card.new(card_name, card_data)
      card_data["*"].each do |set_code, printing_data|
        printing = CardPrinting.new(
          card,
          @sets[set_code],
          printing_data
        )
        card.printings << printing
        @sets[set_code].printings << printing
      end
      card.first_release_date
      card.last_release_date
    end
  end

  def load_products!
    @products = []

    products_data.each do |product_data|
      set = @sets[product_data["set_code"]]
      unless set
        warn "Can't find set #{product_data["set_code"]} for product #{product_data["name"]}"
        next
      end
      product = Product.new(set, product_data)
      @products << product
      set.products << product
    end

    Product.link_products(self)
  end

  def load_limited_formats!
    @limited_formats = []

    limited_formats_data.each do |set_code, set_data|
      set = @sets[set_code]
      unless set
        warn "Can't find set #{set_code} for limited formats"
        next
      end
      set_data.each do |type, format_data|
        limited_format = LimitedFormat.new(self, set, type, format_data)
        @limited_formats << limited_format
        set.limited_formats << limited_format
      end
    end

    @limited_formats.each(&:verify_promo_cards!)
  end

  # Change card number to CardPrinting reference
  def resolve_references!
    @sets.each do |set_code, set|
      set.printings.each do |card|
        if card.partner
          partner = set.printing_by_number[card.partner] or raise "Bad partner number #{partner}"
          card.partner = partner
        end
        if card.others
          card.others = card.others.map{|other|
            set.printing_by_number[other] or raise "Bad other number #{other}"
          }
        end
      end
    end
  end

  def index_cards_in_precons!
    @cards_in_precons = {}
    @sets.values
      .flat_map(&:decks)
      .flat_map(&:cards_in_all_zones)
      .map(&:last)
      .flat_map{|c| c.parts.map(&:name).map{|n| [c.set_code, c.foil, n] }}
      .each do |set_code, foil, name|
        @cards_in_precons[set_code] ||= [Set.new, Set.new]
        @cards_in_precons[set_code][foil ? 1 : 0] << name
      end
  end

  def setup_artists!
    # One slug per artist, but this runs once per printing - a few thousand
    # artists were being slugged a hundred thousand times over.
    slugs = {}
    each_printing do |printing|
      artist_name = printing.artist_name
      artist_slug = slugs[artist_name] ||=
        artist_name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
      @artists[artist_slug] ||= Artist.new(artist_name)
      artist = @artists[artist_slug]
      unless artist_name == artist.name
        warn "Different artists have same slug - `#{artist_name}' `#{artist.name}'"
      end
      artist.printings << printing
      printing.artist = artist
    end
  end

  # Indexes to speed up sort:
  def setup_sort_indexes!
    # Card numbers sort as [number_i, number], and there are only a few thousand
    # distinct ones, so index them once instead of comparing pairs every sort
    number_sort_indexes = printings.map{|c| [c.number_i, c.number]}.uniq.sort.each_with_index.to_h
    printings.each do |c|
      c.number_sort_index = number_sort_indexes[[c.number_i, c.number]]
    end

    printings.sort_by{|c|
      [
        c.name,
        c.nontraditional ? 1 : 0,
        c.digital ? 1 : 0,
        c.frame == "old" ? 1 : 0,
        c.set.regular? ? 0 : 1,
        -c.release_date_i,
        c.set.name,
        c.number_sort_index,
      ]
    }.each_with_index do |c, i|
      c.default_sort_index = i
    end

    @artists.each_value.sort_by{|a| a.name.downcase}.each_with_index do |a, i|
      a.sort_index = i
    end

    @cards.each_value.sort_by(&:name).each_with_index do |c, i|
      c.name_sort_index = i
    end

    @sets.each_value.sort_by(&:name).each_with_index do |s, i|
      s.name_sort_index = i
    end

    # sort:number is set name then card number, and that pair is unique per
    # printing, so one index covers both - needs the two above to be set first
    printings.sort_by{|c| [c.set.name_sort_index, c.number_sort_index]}.each_with_index do |c, i|
      c.set_number_sort_index = i
    end
  end

  def normalize_text(text)
    text.downcase.normalize_accents.strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end

  def spelling_suggestions
    @spelling_suggestions ||= begin
      ss = SpellingSuggestions.new
      @cards.each_key do |title|
        ss << title
      end
      ss
    end
  end

end

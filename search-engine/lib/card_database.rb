require "json"
require "nokogiri"
require "pathname"
require "set"
require "yaml"
require_relative "artist"
require_relative "card_printing"
require_relative "card_set"
require_relative "card_sheet_factory"
require_relative "card_sheet"
require_relative "card"
require_relative "color_balanced_card_sheet"
require_relative "card_sheet_with_duplicates"
require_relative "fixed_card_sheet"
require_relative "color"
require_relative "deck_database"
require_relative "deck_parser"
require_relative "deck"
require_relative "pack_factory"
require_relative "pack"
require_relative "physical_card"
require_relative "precon_deck"
require_relative "product"
require_relative "query"
require_relative "sealed"
require_relative "spelling_suggestions"
require_relative "unknown_card"
require_relative "user_deck_parser"
require_relative "weighted_pack"

# Backport from >=2.4 to 2.3
module Enumerable
  def sum(accumulator = 0, &block)
    values = block_given? ? map(&block) : self
    values.inject(accumulator, :+)
  end unless method_defined? :sum
end

class String
  # This is a much longer list than just what's on cards as:
  # * it's also artist names
  # * everything is both upper and lower case,
  #   even if only one case is actually in print
  def normalize_accents
    result = gsub("Æ", "Ae")
      .gsub("æ", "ae")
      .gsub("Œ", "Oe")
      .gsub("œ", "oe")
      .tr(
        "ÀÁÂÄẤàáâäãấĆČÇćčçÈËÊÉèéêëēǵÍÏĪÎíïīîŁłÑñńÓÖØõöóøÛÜÚúûüŠšÝýŻż’\u2212",
        "AAAAAaaaaaaCCCcccEEEEeeeeegIIIIiiiiLlNnnOOOooooUUUuuuSsYyZz'-")
    result = self if result == self # Memory saving trick
    -result
  end
end

class CardDatabase
  attr_reader :sets, :cards, :blocks, :artists, :cards_in_precons

  def initialize
    @sets = {}
    @blocks = Set[]
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
    @printings ||= enum_for(:each_printing).to_set
  end

  def decks
    @decks ||= @sets.values.flat_map(&:decks)
  end

  def booster_data
    @booster_data ||= JSON.parse(Pathname("#{__dir__}/../../index/booster_index.json").read)
  end

  # We also need to include all other cards with same name from same set,
  # as we don't know which Forest etc. is included
  def decks_containing(card_printing)
    set_code = card_printing.set_code
    name = card_printing.name
    decks.select do |deck|
      next unless deck.all_set_codes.include?(set_code)
      [*deck.cards, *deck.sideboard, *deck.commander].any? do |_, physical_card|
        physical_card.parts.any? do |physical_card_part|
          if ConditionDeck::CardsWithAllowedConflicts.include?(physical_card.name)
            physical_card_part.set_code == card_printing.set_code and
            physical_card_part.name == card_printing.name
          else
            physical_card_part == card_printing
          end
        end
      end
    end
  end

  def subset(sets)
    # puts "Loading subset: #{sets}"
    self.class.send(:new) do |db|
      db.send(:load_from_subset!, self, sets)
    end
  end

  def pack_factory
    @pack_factory ||= PackFactory.new(self)
  end

  # Excluding unsupported ones
  # It's a very slow method, so memoize, but better just make it fast
  def supported_booster_types
    unless @supported_booster_types
      @supported_booster_types = {}
      booster_data.each_key do |booster_code|
        set_code, variant = booster_code.split("-", 2)
        booster = pack_factory.for(set_code, variant)
        @supported_booster_types[booster.code] = booster if booster
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

  # Whetever we list supported booster types, skip aliases
  def unique_supported_booster_types
    @unique_supported_booster_types ||= supported_booster_types.select{|code, booster| code == booster.code}
  end

  def promo_types
    @promo_types ||= printings.flat_map(&:promo_types).uniq.compact.to_set
  end

  def frame_effects
    @frame_effects ||= printings.flat_map(&:frame_effects).uniq.compact.to_set
  end

  # CardPrinting.in_boosters is only available from this point
  def initialize_booster_flag
    @supported_booster_types.each_value do |booster|
      booster.cards.each do |physical_card|
        physical_card.parts.each do |card_printing|
          card_printing.in_boosters = true
        end
      end
    end
  end

  # Exclude Arena boosters
  # It will generally be XXX-play now
  def most_recent_booster_type
    @most_recent_booster_type ||= supported_booster_types[supported_booster_types.reject{|k,v| k.include?("-")}.first.first].code
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
      raise "Can't parse time #{time}"
    end
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  #
  # Priority:
  # * exact code (official)
  # * exact alternative code (mci)
  # * name exact match
  # * name substring match
  def resolve_editions(edition)
    edition = edition.downcase

    # Just don't bother with anything fancy if "e:foo" exists as a code
    if @sets[edition]
      return Set[@sets[edition]]
    end

    matching_alternative_code = Set[]
    matching_name = Set[]
    matching_name_part = Set[]

    normalized_edition = normalize_set_name(edition)
    normalized_edition_alt = normalize_set_name_alt(edition)

    @sets.each do |set_code, set|
      normalized_set_name     = set.normalized_name
      normalized_set_name_alt = set.normalized_name_alt
      matching_primary_code     << set if set_code == edition
      matching_alternative_code << set if set.alternative_code&.downcase == edition
      matching_name          << set if normalized_set_name == normalized_edition or normalized_set_name_alt == normalized_edition_alt
      matching_name_part     << set if normalized_set_name.include?(normalized_edition) or normalized_set_name_alt.include?(normalized_edition_alt)
    end

    [
      matching_alternative_code,
      matching_name,
      matching_name_part,
    ].find{|s| s.size > 0} || Set[]
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

  def normalize_set_name(name)
    normalize_text(name).downcase.gsub("'s", "s").split(/[^a-z0-9]+/).join(" ")
  end

  def normalize_set_name_alt(name)
    normalize_text(name).downcase.gsub("'s", "").split(/[^a-z0-9]+/).join(" ")
  end

  def resolve_edition(edition)
    editions = resolve_editions(edition).to_a
    return editions[0] if editions.size <= 1
    raise "Ambiguous set name #{edition}, matches #{editions.size} sets"
  end

  class <<self
    private :new

    def load(path=Pathname("#{__dir__}/../../index/index.json"))
      new do |db|
        db.send(:load_from_json!, Pathname(path))
      end
    end
  end

  def suggest_spelling(word)
    spelling_suggestions.suggest(word)
  end

  def number_of_cards
    @cards.size
  end

  def number_of_printings
    printings.size
  end

  def has_card_named?(name)
    c = cards[normalize_name(name)]
    !!c and c.name == name
  end

  private

  def freeze_strings!(data)
    case data
    when Array
      data.each_with_index do |v,i|
        if v.is_a?(Array) or v.is_a?(Hash)
          freeze_strings!(v)
        elsif v.is_a?(String)
          data[i] = -v
        end
      end
    when Hash
      data.each do |k,v|
        if v.is_a?(Array) or v.is_a?(Hash)
          freeze_strings!(v)
        elsif v.is_a?(String)
          data[k] = -v
        end
      end
    end
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
  end

  def load_from_json!(path)
    data = JSON.parse(path.open.read)
    freeze_strings!(data)
    data["sets"].each do |set_code, set_data|
      @sets[set_code] = CardSet.new(self, set_data)
      if set_data["block_code"]
        @blocks << set_data["block_code"]
        @blocks << set_data["alternative_block_code"] if set_data["alternative_block_code"]
        @blocks << normalize_name(set_data["block_name"])
      end
    end
    data["cards"].each do |card_name, card_data|
      # Indexer removes most tokens, we allow only a very selected group of very special ones
      # next if card_data["layout"] == "token"
      normalized_name = card_name.downcase.normalize_accents
      card = @cards[normalized_name] = Card.new(card_data.reject{|k,_| k == "*"})
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
    resolve_references!
    setup_artists!
    setup_sort_index!
    DeckDatabase.new(self).load!
    index_cards_in_precons!
  end

  # Change card number to CardPrinting reference
  def resolve_references!
    @sets.each do |set_code, set|
      set.printings.each do |card|
        if card.partner
          partner = set.printings.find{|c| c.number == card.partner} or raise "Bad partner number #{partner}"
          card.partner = partner
        end
        if card.others
          card.others = card.others.map{|other|
            set.printings.find{|c| c.number == other} or raise "Bad other number #{other}"
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
    each_printing do |printing|
      artist_name = printing.artist_name
      if artist_name.nil?
        warn "No artist for #{printing}"
        artist_name = "unknown"
      end
      artist_slug = artist_name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
      @artists[artist_slug] ||= Artist.new(artist_name)
      artist = @artists[artist_slug]
      unless artist_name == artist.name
        warn "Different artists have same slug - `#{artist_name}' `#{artist.name}'"
      end
      artist.printings << printing
      printing.artist = artist
    end
  end

  def setup_sort_index!
    printings.sort_by{|c|
      [
        c.name,
        c.nontournament ? 1 : 0,
        c.online_only? ? 1 : 0,
        c.frame == "old" ? 1 : 0,
        c.set.regular? ? 0 : 1,
        -c.release_date_i,
        c.set.name,
        c.number_i,
        c.number,
      ]
    }.each_with_index do |c, i|
      c.default_sort_index = i
    end
  end

  # These method seem to occur in every single class out there
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

  def inspect
    "CardDatabase"
  end
end

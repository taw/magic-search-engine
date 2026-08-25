require_relative "bitmap_flag"
require_relative "index_format"

class CardPrinting
  extend BitmapFlag

  # The six game flags come first so GAMES below stays a 64 entry table
  FLAG_BITS = bitmap_flags(
    :paper,
    :mtgo,
    :arena,
    :shandalar,
    :dreamcast,
    :xmage,
    :baseset,
    :digital,
    :etched,
    :fullart,
    :in_boosters,
    :main_front,
    :nontournament,
    :nontraditional,
    :oversized,
    :spotlight,
    :textless,
    :timeshifted,
    :token,
    :variant_arena,
    :variant_foreign,
    :variant_misprint,
  )

  # Most physical cards have no back, so they can all share one empty array.
  NO_PARTS = [].freeze

  # Which flag each character of the index's "!" string sets, see IndexFormat.
  # The negated ones start out set and their character clears them.
  FLAG_SETTERS = IndexFormat::FLAGS.to_h{|name, char| [char, :"#{name}="] }.freeze
  NEGATED_FLAG_SETTERS = IndexFormat::NEGATED_FLAGS.to_h{|name, char| [char, :"#{name}="] }.freeze

  GAME_NAMES = {
    "paper"     => :paper,
    "mtgo"      => :mtgo,
    "arena"     => :arena,
    "shandalar" => :shandalar,
    "dreamcast" => :dreamcast,
    "xmage"     => :xmage,
  }.freeze
  GAMES_MASK = FLAG_BITS.values_at(*GAME_NAMES.values).inject(:|)
  raise "game flags must be declared first" unless GAMES_MASK == (1 << GAME_NAMES.size) - 1
  # Only 64 combinations, so build them all rather than memoize one per printing
  GAMES = (0..GAMES_MASK).map{|bits|
    GAME_NAMES.filter_map{|name, flag| name if bits & FLAG_BITS[flag] != 0 }.freeze
  }.freeze

  attr_reader(
    :artist_name,
    :attraction_lights,
    :border,
    :card,
    :flavor_name,
    :flavor_normalized,
    :flavor,
    :foiling,
    :frame_effects,
    :frame,
    :language,
    :multiverseid,
    :number,
    :print_sheet,
    :promo_types,
    :rarity_code,
    :release_date,
    :set,
    :signature,
    :stamp,
    :stemmed_flavor_name,
    :subsets,
    :watermark,
  )

  # Performance cache of derived information
  attr_reader :stemmed_name, :set_code, :release_date_i, :number_i, :types

  # Set by CardDatabase initialization
  attr_accessor :others, :artist, :default_sort_index, :partner
  # Set by CardDatabase initialization, printings ordered by [number_i, number]
  attr_accessor :number_sort_index
  # Set by CardDatabase initialization, printings ordered by [set name, number]
  attr_accessor :set_number_sort_index
  # Set by the frontend
  attr_accessor :image_path

  def initialize(card, set, data)
    @flags = 0
    @card = card
    @set = set
    @others = nil
    @release_date = data["d"] ? Date.parse(data["d"]) : @set.release_date
    @release_date_i = @release_date.to_i_sort
    @watermark = data["w"]
    @number = data["n"]
    @number_i = @number.to_i
    @multiverseid = data["m"]
    @artist_name = data["a"].normalize_accents
    @flavor = data["fl"] || -""
    @flavor_name = data["fn"]
    @flavor_normalized = @flavor.normalize_accents
    if @flavor_name
      @stemmed_flavor_name = -@flavor_name.downcase.normalize_accents.gsub(/s\b/, "").tr("-", " ")
    end
    @foiling = IndexFormat::FOILING_SYMBOLS.fetch(data["fo"] || 0)
    @border = IndexFormat::BORDERS.fetch(data["b"] || 0)
    @frame = IndexFormat::FRAMES.fetch(data["f"] || 0)
    @frame_effects = data["fe"] || []
    @rarity_code = data["r"]
    @attraction_lights = data["al"]
    @language = data["l"]
    @others = data["o"] # overridden by CardDatabase
    @partner = data["pr"] # overridden by CardDatabase
    @print_sheet = data["ps"]
    @promo_types = data["p"]
    @signature = data["sg"]
    @stamp = data["s"] && IndexFormat::STAMPS.fetch(data["s"])
    @subsets = data["ss"]

    self.mtgo = true
    self.paper = true
    self.xmage = true
    (data["!"] || "").each_char do |char|
      if (setter = FLAG_SETTERS[char])
        send(setter, true)
      else
        send(NEGATED_FLAG_SETTERS.fetch(char), false)
      end
    end
    self.baseset = calculate_baseset

    # Performance cache
    @stemmed_name = @card.stemmed_name
    @set_code = @set.code
    @types = @card.types
  end

  # Same games as game: queries know about
  def games
    GAMES[@flags & GAMES_MASK]
  end

  def rarity
    IndexFormat::RARITIES.fetch(@rarity_code)
  end

  def ui_rarity
    if @print_sheet
      "#{rarity} (#{@print_sheet})"
    else
      rarity
    end
  end

  def year
    @release_date.year
  end

  # This is a bit too performance-critical to use method_missing
  # It's not a huge difference, but no reason to waste ~5% of execution time on it
  def set_name
    @set.name
  end

  %W[block_code block_name].each do |m|
    eval("def #{m}; @set.#{m}; end")
  end
  %W[
    alchemy
    allowed_in_any_number?
    augment
    back?
    brawler?
    cmc
    color_identity
    color_indicator
    color_indicator_colors
    colors
    commander?
    count_paperprints
    count_papersets
    count_prints
    count_sets
    custom?
    decklimit
    default_printing
    defense
    display_mana_cost
    display_power
    display_toughness
    first_regular_release_date
    first_release_date
    foreign_names
    foreign_names_normalized
    front?
    fulltext
    fulltext_normalized
    funny
    game_changer
    hand
    has_alchemy
    has_multiple_parts?
    in_spellbook
    keywords
    last_release_date
    layout
    life
    loyalty
    mana_cost
    mana_hash
    modal
    mv
    name
    name_slug
    name_sort_index
    names
    partner?
    power
    primary?
    printings
    produces
    related
    reminder_text
    reserved
    rulings
    secondary?
    short_name
    special_format
    specialized
    specializes
    spellbook
    text
    text_normalized
    toughness
    type_group
    typeline
  ].each do |m|
    eval("def #{m}; @card.#{m}; end")
  end

  def legality_information(time=nil)
    @card.legality_information(time)
  end

  def gatherer_link
    return nil unless multiverseid
    "http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=#{multiverseid}"
  end

  include Comparable

  def <=>(other)
    default_sort_index <=> other.default_sort_index
  end

  def age
    @age ||= [0, (release_date - first_regular_release_date).to_i].max
  end

  def inspect
    "CardPrinting(#{name}, #{set_code}/#{number})"
  end

  def id
    "#{set_code}/#{number}"
  end

  def to_s
    inspect
  end

  # There are 3 scenarios:
  # * both have "Partner"
  # * both have "Partner with" and they point at each other
  # * one is The Doctor, and the other has "Doctor's Companion"
  def valid_partner_for?(other)
    return true if the_doctor? and other.doctors_companion?
    return true if other.the_doctor? and self.doctors_companion?

    return unless partner? and other.partner?
    if partner
      return false unless partner.name == other.name
    end
    if other.partner
      return false unless name == other.partner.name
    end
    true
  end

  # For sake of Doctor's companion
  def the_doctor?
    types.to_set == Set["creature", "time-lord", "doctor", "legendary"]
  end

  def doctors_companion?
    text.include?("Doctor's companion")
  end

  # The printing whose physical card this one is a face of, which is what
  # PhysicalCard is built from. A melded card is on two physical cards' backs,
  # and `others` lists both of its fronts, the top half first - see PatchMeld -
  # so it goes with the physical card whose back is its top half.
  def main_front
    main_front? ? self : @others.find(&:main_front?)
  end

  # The faces of the physical card this printing is the main front of, split
  # into front and back, in printed order. Nothing here sorts: `others` already
  # arrives in printed order, because the indexer builds it from mtgjson's
  # `names`, the same order it turns into the "a" / "b" number suffixes.
  def physical_front_parts
    return [self] unless multipart_physical_card?
    [self, *@others].select(&:front?)
  end

  def physical_back_parts
    return NO_PARTS unless multipart_physical_card?
    back_parts = @others.select(&:back?)
    back_parts.empty? ? NO_PARTS : back_parts
  end

  # Is this printing the face that PhysicalCard identity is based on?
  # Precomputed, as `is:mainfront` would otherwise build a PhysicalCard for every card it looks at.

  # Called by CardDatabase once `others` references are resolved.
  def calculate_main_front!
    self.main_front =
      if !multipart_physical_card?
        true
      elsif !front?
        false
      else
        # Split cards and the like have every face on the front, and only the
        # first printed one is the main front. `others` cannot say which that
        # is, as it leaves out the printing itself, so compare numbers - by
        # number_sort_index, as numbers are strings that put "10" before "9".
        [self, *@others].select(&:front?).min_by(&:number_sort_index).equal?(self)
      end
  end

  def physical_card
    PhysicalCard.for(self)
  end

  def foilonly?
    foiling == :foilonly
  end

  def nonfoilonly?
    foiling == :nonfoil
  end

  # Whether the card was printed in one of PhysicalCard's finishes. `:foil` is
  # any premium finish, the same question `is:foil` asks - mtgjson lists plain
  # foil and etched separately, but the index only keeps `etched`, so a card
  # that came etched cannot be asked whether it also came in plain foil.
  def has_finish?(finish)
    case finish
    when :nonfoil
      foiling != :foilonly
    when :foil
      foiling != :nonfoil
    when :etched
      etched
    else
      raise "Unknown finish #{finish.inspect}"
    end
  end

  # mtgjson has B.F.M.'s two halves as one multipart card, but they are two
  # separate physical cards, each just its own face.
  def multipart_physical_card?
    has_multiple_parts? and name != "B.F.M. (Big Furry Monster)" and name != "B.F.M. (Big Furry Monster, Right Side)"
  end

  def calculate_baseset
    return false if variant_arena or variant_foreign or variant_misprint or promo_types&.include?("reversibleback")
    base_set_size = set.base_set_size
    return false unless base_set_size
    number_i >= 1 and number_i <= base_set_size
  end
end

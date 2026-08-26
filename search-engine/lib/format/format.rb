# Previously supported formats: Standard Brawl, Frontier, MTGO Commander

class Format
  # Statuses which all mean "in the format, but with a deckbuilding restriction".
  # They're displayed and validated differently, but restricted: and f: searches
  # treat them all the same way, which is how "restricted" behaved when it was
  # the only name for all of them.
  #
  # Sets rather than arrays because these are only ever asked include?, and the
  # value asked about is usually nil (card isn't in the format) - which is the
  # one case where Array#include? falls off a cliff, comparing a String to a
  # non-String five times through respond_to?(:to_str).
  RESTRICTED_STATUSES = Set[
    "restricted",
    "banned_as_commander",
    "banned_as_companion",
    "conjurable",
    "specialized",
  ].freeze

  # What f: and format: match: in the format at all, restricted or not
  LEGAL_OR_RESTRICTED_STATUSES = Set["legal", *RESTRICTED_STATUSES].freeze

  attr_reader :included_sets, :excluded_sets

  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList[ban_list_name]
    if respond_to?(:build_included_sets)
      @included_sets = build_included_sets
      @excluded_sets = nil
    else
      @included_sets = nil
      @excluded_sets = build_excluded_sets
    end
  end

  def legality(card)
    card = card.main_front if card.is_a?(PhysicalCard)
    if card.special_format or !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  # These deliberately don't go through legality, because they want the two
  # checks in the opposite order. legality has to return the real status, so it
  # asks in_format? first and only then the ban list. banned? and restricted?
  # only need to know whether one specific answer applies, and a card the ban
  # list has never heard of can't be either - which is 99.8% of the index,
  # settled by a hash lookup instead of walking every printing of every card.
  #
  # The card.special_format term is what legality applies too - planes, schemes,
  # vanguards, conspiracies and Hero's Path cards are legal in no format at any
  # date, so the ban list never gets a say about them.
  def banned?(card)
    card = card.main_front if card.is_a?(PhysicalCard)
    return false unless @ban_list.legality(card.name, @time) == "banned"
    !card.special_format and in_format?(card)
  end

  def restricted?(card)
    card = card.main_front if card.is_a?(PhysicalCard)
    return false unless RESTRICTED_STATUSES.include?(@ban_list.legality(card.name, @time))
    !card.special_format and in_format?(card)
  end

  def legal?(card)
    legality(card) == "legal"
  end

  def legal_or_restricted?(card)
    LEGAL_OR_RESTRICTED_STATUSES.include?(legality(card))
  end

  def in_format?(card)
    # mtgjson files Alchemy cards in the same set as the paper cards they rebalance
    # instead of giving them their own set, so without this every format would count
    # them as printings of its own sets. Alchemy, Historic and Timeless, where they're
    # real cards rather than noise, override this method.
    return false if card.alchemy
    card.printings.each do |printing|
      # Only a printing you could bring to a sanctioned event can make a card legal.
      # This is per-printing rather than per-card so that mixed products come out right
      # without anyone maintaining a list: MB2's ordinary reprints are legal while its
      # playtest cards are not, and Counterspell stays legal despite sld/sctlr.
      next if printing.nontournament
      next if @time and printing.release_date > @time
      if @included_sets
        next unless @included_sets.include?(printing.set_code)
      else
        next if @excluded_sets.include?(printing.set_code)
      end
      return true
    end
    false
  end

  def cards_probably_in_format(db)
    if @included_sets
      @included_sets.flat_map do |set_code|
        # This will only be nil in subset of db, so really only in tests
        set = db.sets[set_code]
        set ? set.printings.map(&:card) : []
      end.to_set
    else
      db.cards.values
    end
  end

  def deck_issues(deck)
    [
      *deck_size_issues(deck),
      *deck_card_issues(deck),
    ]
  end

  def deck_size_issues(deck)
    issues = []
    if deck.number_of_mainboard_cards < 60
      issues << "Deck must contain at least 60 mainboard cards, has only #{deck.number_of_mainboard_cards}"
    end
    if deck.number_of_sideboard_cards > 15
      issues << "Deck must contain at most 15 sideboard cards, has #{deck.number_of_sideboard_cards}"
    end
    if deck.number_of_commander_cards > 0
      issues << "Format does not support commanders"
    end
    issues
  end

  # individual cards can override this
  def default_max_copies_allowed
    4
  end

  # Card text overrides the format's limit in either direction (CR 100.2a) -
  # "up to seven cards named" beats singleton, "only one card named" beats four.
  def max_copies_allowed(card)
    case card.decklimit
    when nil
      default_max_copies_allowed
    when "any"
      Float::INFINITY
    else
      card.decklimit
    end
  end

  def deck_card_issues(deck)
    issues = []
    deck.card_counts.each do |card, name, count|
      card_legality = legality(card)
      case card_legality
      # banned_as_companion is not deck construction issue - companion cards are always sideboard
      #   you just can't reveal them before game to use as your companion
      # banned_as_commander is checked by deck_commander_issues in format where it's applicable
      when "legal", "banned_as_companion", "banned_as_commander"
        max_copies = max_copies_allowed(card)
        if count > max_copies
          issues << "Deck contains #{count} copies of #{name}, only up to #{max_copies} allowed"
        end
      when "restricted"
        if count > 1
          issues << "Deck contains #{count} copies of #{name}, which is restricted to only up to 1 allowed"
        end
      when "conjurable"
        issues << "#{name} is conjurable only and cannot be used as part of deck construction"
      when "specialized"
        issues << "#{name} is specialized only and cannot be used as part of deck construction"
      when "banned"
        issues << "#{name} is banned"
      else
        issues << "#{name} is not in the format"
      end
    end
    issues
  end

  def format_pretty_name
    raise "Subclass responsibility"
  end

  def format_name
    format_pretty_name.downcase
  end

  # Date the format started, as "yyyy-mm-dd" string, or nil if we don't know.
  # Block constructed formats start with their first set.
  # Other formats need a clear format start announcement to be filled in here.
  def format_start_date
    nil
  end

  # Only formats which actually rotate have a rotation schedule worth showing
  def display_rotation_schedule?
    false
  end

  # Formats which don't have a ban list of their own can borrow someone else's
  def ban_list_name
    format_name
  end

  def to_s
    if @time
      "<Format:#{format_name}:#{@time}>"
    else
      "<Format:#{format_name}>"
    end
  end

  def inspect
    to_s
  end

  def ban_events
    @ban_list.events
  end

  class << self
    def formats_index
      # Removed spaces so you can say "lw block" lw-block lwblock lw_block or whatever
      {
        "iablock"                    => FormatIceAgeBlock,
        "iceageblock"                => FormatIceAgeBlock,
        "mrblock"                    => FormatMirageBlock,
        "mirageblock"                => FormatMirageBlock,
        "tpblock"                    => FormatTempestBlock,
        "tempestblock"               => FormatTempestBlock,
        "usblock"                    => FormatUrzaBlock,
        "urzablock"                  => FormatUrzaBlock,
        "mmblock"                    => FormatMasquesBlock,
        "masquesblock"               => FormatMasquesBlock,
        "marcadianmasquesblock"      => FormatMasquesBlock,
        "inblock"                    => FormatInvasionBlock,
        "invasionblock"              => FormatInvasionBlock,
        "odblock"                    => FormatOdysseyBlock,
        "odysseyblock"               => FormatOdysseyBlock,
        "onblock"                    => FormatOnslaughtBlock,
        "onslaughtblock"             => FormatOnslaughtBlock,
        "miblock"                    => FormatMirrodinBlock,
        "mirrodinblock"              => FormatMirrodinBlock,
        "tsblock"                    => FormatTimeSpiralBlock,
        "timespiralblock"            => FormatTimeSpiralBlock,
        "ravblock"                   => FormatRavnicaBlock,
        "ravnicablock"               => FormatRavnicaBlock,
        "kamigawablock"              => FormatKamigawaBlock,
        "chkblock"                   => FormatKamigawaBlock,
        "championsofkamigawablock"   => FormatKamigawaBlock,
        "lwblock"                    => FormatLorwynBlock,
        "lorwynblock"                => FormatLorwynBlock,
        "lorwynshadowmoorblock"      => FormatLorwynBlock,
        "alablock"                   => FormatShardsOfAlaraBlock,
        "alarablock"                 => FormatShardsOfAlaraBlock,
        "shardsofalarablock"         => FormatShardsOfAlaraBlock,
        "zendikarblock"              => FormatZendikarBlock,
        "zenblock"                   => FormatZendikarBlock,
        "scarsofmirrodinblock"       => FormatScarsOfMirrodinBlock,
        "somblock"                   => FormatScarsOfMirrodinBlock,
        "innistradblock"             => FormatInnistradBlock,
        "isdblock"                   => FormatInnistradBlock,
        "returntoravnicablock"       => FormatReturnToRavnicaBlock,
        "rtrblock"                   => FormatReturnToRavnicaBlock,
        "therosblock"                => FormatTherosBlock,
        "thsblock"                   => FormatTherosBlock,
        "tarkirblock"                => FormatTarkirBlock,
        "ktkblock"                   => FormatTarkirBlock,
        "khansoftarkirblock"         => FormatTarkirBlock,
        "battleforzendikarblock"     => FormatBattleForZendikarBlock,
        "bfzblock"                   => FormatBattleForZendikarBlock,
        "soiblock"                   => FormatShadowsOverInnistradBlock,
        "shadowsoverinnistradblock"  => FormatShadowsOverInnistradBlock,
        "kldblock"                   => FormatKaladeshBlock,
        "kaladeshblock"              => FormatKaladeshBlock,
        "akhblock"                   => FormatAmonkhetBlock,
        "amonkhetblock"              => FormatAmonkhetBlock,
        "ixalanblock"                => FormatIxalanBlock,
        "xlnblock"                   => FormatIxalanBlock,
        "unsets"                     => FormatUnsets,
        "un-sets"                    => FormatUnsets,
        "standard"                   => FormatStandard,
        # Not a real format, just Standard as it will be after the next rotation
        "future"                     => FormatFuture,
        "futurestandard"             => FormatFuture,
        # Disabled for now. Arena runs three Brawl queues and the official B&R list
        # tracks only the other two, so this is the one nobody plays.
        # "standardbrawl"              => FormatStandardBrawl,
        "brawl"                      => FormatBrawl,
        # What it was called until the 2023-12-12 client update
        "historicbrawl"              => FormatBrawl,
        "competitivebrawl"           => FormatCompetitiveBrawl,
        # What it was called for the week between announcement and launch
        "rankedbrawl"                => FormatCompetitiveBrawl,
        "modern"                     => FormatModern,
        "pioneer"                    => FormatPioneer,
        "legacy"                     => FormatLegacy,
        "vintage"                    => FormatVintage,
        "pauper"                     => FormatPauper,
        "pennydreadful"              => FormatPennyDreadful,
        "pd"                         => FormatPennyDreadful,
        "penny"                      => FormatPennyDreadful,
        "commander"                  => FormatCommander,
        "edh"                        => FormatCommander,
        "duelcommander"              => FormatDuelCommander,
        "dueledh"                    => FormatDuelCommander,
        "duel"                       => FormatDuelCommander,
        "historic"                   => FormatHistoric,
        "timeless"                   => FormatTimeless,
        "premodern"                  => FormatPremodern,
        "alchemy"                    => FormatAlchemy,
      }
    end

    def all_format_classes
      @all_format_classes ||= formats_index.values.uniq
    end

    def [](format_name)
      format_name = format_name.downcase.gsub(/\s|-|_/, "")
      return FormatAny if format_name == "*"
      formats_index[format_name] || FormatUnknown
    end
  end
end

require_relative "format_vintage"
require_relative "format_standard"
require_relative "format_commander"
# FormatTimeless and FormatBrawl subclass it
require_relative "format_historic"
# The Brawl formats include it
require_relative "brawl_deck_rules"
Dir["#{__dir__}/format_*.rb"].sort.each do |path| require_relative path end

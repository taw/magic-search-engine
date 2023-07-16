class Format
  attr_reader :included_sets, :excluded_sets

  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList[format_name]
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
    if card.extra or !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  def banned?(card)
    legality(card) == "banned"
  end

  def restricted?(card)
    legality(card) == "restricted"
  end

  def legal?(card)
    legality(card) == "legal"
  end

  def legal_or_restricted?(card)
    l = legality(card)
    l == "legal" or l == "restricted"
  end

  def in_format?(card)
    return false if card.funny
    return false if card.alchemy
    card.printings.each do |printing|
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

  def deck_card_issues(deck)
    issues = []
    deck.card_counts.each do |card, name, count|
      card_legality = legality(card)
      case card_legality
      when "legal"
        if count > 4 and not card.allowed_in_any_number?
          issues << "Deck contains #{count} copies of #{name}, only up to 4 allowed"
        end
      when "restricted"
        if count > 1
          issues << "Deck contains #{count} copies of #{name}, which is restricted to only up to 1 allowed"
        end
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
        "ravblock"                   => FormatRavinicaBlock,
        "ravnicablock"               => FormatRavinicaBlock,
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
        "brawl"                      => FormatBrawl,
        "modern"                     => FormatModern,
        "frontier"                   => FormatFrontier,
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
        "mtgocommander"              => FormatMTGOCommander,
        "mtgoedh"                    => FormatMTGOCommander,
        "historic"                   => FormatHistoric,
        "premodern"                  => FormatPremodern,
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
Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end

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

  def include_custom_sets?
    false
  end

  def deck_legality(deck)
    # Returns nil if the deck is legal, or an error message if it's not. If there are multiple issues that make the deck illegal, only one of them is returned.
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card).nil? }
    return "#{offending_card.name} is not legal in #{format_pretty_name}." unless offending_card.nil?
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card) == "banned" }
    return "#{offending_card.name} is banned in #{format_pretty_name}." unless offending_card.nil?
    min_mainboard_size = 60 - 5 * deck.sideboard.select{|iter_card| iter_card.last.name == "Advantageous Proclamation"}.map(&:first).inject(0, &:+) # assumes all Proclamations in the sideboard are used
    return "Minimum mainboard size is #{min_mainboard_size} cards, but this deck only has #{deck.number_of_mainboard_cards}." if deck.number_of_mainboard_cards < min_mainboard_size
    return "Maximum sideboard size is 15 cards, but this deck has #{deck.number_of_sideboard_cards}." if deck.number_of_sideboard_cards > 15
    offending_card = deck.physical_cards.map(&:main_front).find{|card| !card.allowed_in_any_number? && deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == card.name}.map(&:first).inject(0, &:+) > 4 }
    unless offending_card.nil?
      count = deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == offending_card.name}.map(&:first).inject(0, &:+)
      return "A maximum of 4 copies of the same nonbasic card are allowed, but this deck has #{count} copies of #{offending_card.name}."
    end
    offending_card = deck.physical_cards.map(&:main_front).find{|card| legality(card) == "restricted" && deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == card.name}.map(&:first).inject(0, &:+) > 1 }
    unless offending_card.nil?
      count = deck.cards_with_sideboard.select{|iter_card| iter_card.last.main_front.name == offending_card.name}.map(&:first).inject(0, &:+)
      return "#{offending_card.name} is restricted in #{format_pretty_name} so only one copy is allowed per deck, but this deck has #{count} copies."
    end
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      if !include_custom_sets?
        next if card.custom?
      end
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
        "customstandard"             => FormatCustomStandard,
        "custard"                    => FormatCustomStandard,
        "cstd"                       => FormatCustomStandard,
        "cs"                         => FormatCustomStandard,
        "custometernal"              => FormatCustomEternal,
        "ce"                         => FormatCustomEternal,
        "custommodern"               => FormatCustomModern,
        "cmod"                       => FormatCustomModern,
        "cm"                         => FormatCustomModern,
        "fusiondragonhighlander"     => FormatFDH,
        "fdh"                        => FormatFDH,
        "fusioncommander"            => FormatFDH,
        "fusionedh"                  => FormatFDH,
        "eldercockatricehighlander"  => FormatECH,
        "ech"                        => FormatECH,
        "customcommander"            => FormatECH,
        "customedh"                  => FormatECH,
        "cc"                         => FormatECH,
        "cedh"                       => FormatECH,
        "custompauper"               => FormatCustomPauper,
        "cp"                         => FormatCustomPauper,
        "custombrawl"                => FormatCustomBrawl,
        "crawl"                      => FormatCustomBrawl,
        "cb"                         => FormatCustomBrawl,
      }
    end

    def all_format_classes
      formats_index.values.uniq
    end

    def [](format_name)
      format_name = format_name.downcase.gsub(/\s|-|_/, "")
      formats_index[format_name] || FormatUnknown
    end
  end
end

require_relative "format_vintage"
require_relative "format_commander"
require_relative "format_standard"
require_relative "format_commander"
require_relative "format_custom_standard"
require_relative "format_custom_eternal"
Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end

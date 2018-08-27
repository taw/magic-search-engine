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
    if card.extra or !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  def include_custom_sets?
    false
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
        "commander"                  => FormatCommander,
        "edh"                        => FormatCommander,
        "duelcommander"              => FormatDuelCommander,
        "dueledh"                    => FormatDuelCommander,
        "mtgocommander"              => FormatMTGOCommander,
        "mtgoedh"                    => FormatMTGOCommander,
        "customstandard"             => FormatCustomStandard,
        "cstd"                       => FormatCustomStandard,
        "cs"                         => FormatCustomStandard,
        "custometernal"              => FormatCustomEternal,
        "ce"                         => FormatCustomEternal,
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
require_relative "format_custom_eternal"
Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end

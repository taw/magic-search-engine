class Format
  attr_reader :included_sets, :excluded_sets

  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList.new
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
      @ban_list.legality(format_name, card.name, @time)
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

  class << self
    def formats_index
      {
        "ia block"                    => FormatIceAgeBlock,
        "ice age block"               => FormatIceAgeBlock,
        "mr block"                    => FormatMirageBlock,
        "mirage block"                => FormatMirageBlock,
        "tp block"                    => FormatTempestBlock,
        "tempest block"               => FormatTempestBlock,
        "us block"                    => FormatUrzaBlock,
        "urza block"                  => FormatUrzaBlock,
        "mm block"                    => FormatMasquesBlock,
        "masques block"               => FormatMasquesBlock,
        "marcadian masques block"     => FormatMasquesBlock,
        "in block"                    => FormatInvasionBlock,
        "invasion block"              => FormatInvasionBlock,
        "od block"                    => FormatOdysseyBlock,
        "odyssey block"               => FormatOdysseyBlock,
        "on block"                    => FormatOnslaughtBlock,
        "onslaught block"             => FormatOnslaughtBlock,
        "mi block"                    => FormatMirrodinBlock,
        "mirrodin block"              => FormatMirrodinBlock,
        "ts block"                    => FormatTimeSpiralBlock,
        "time spiral block"           => FormatTimeSpiralBlock,
        "rav block"                   => FormatRavinicaBlock,
        "ravnica block"               => FormatRavinicaBlock,
        "kamigawa block"              => FormatKamigawaBlock,
        "chk block"                   => FormatKamigawaBlock,
        "champions of kamigawa block" => FormatKamigawaBlock,
        "lw block"                    => FormatLorwynBlock,
        "lorwyn block"                => FormatLorwynBlock,
        "lorwyn shadowmoor block"     => FormatLorwynBlock,
        "ala block"                   => FormatShardsOfAlaraBlock,
        "alara block"                 => FormatShardsOfAlaraBlock,
        "shards of alara block"       => FormatShardsOfAlaraBlock,
        "zendikar block"              => FormatZendikarBlock,
        "zen block"                   => FormatZendikarBlock,
        "scars of mirrodin block"     => FormatScarsOfMirrodinBlock,
        "som block"                   => FormatScarsOfMirrodinBlock,
        "innistrad block"             => FormatInnistradBlock,
        "isd block"                   => FormatInnistradBlock,
        "return to ravnica block"     => FormatReturnToRavnicaBlock,
        "rtr block"                   => FormatReturnToRavnicaBlock,
        "theros block"                => FormatTherosBlock,
        "ths block"                   => FormatTherosBlock,
        "tarkir block"                => FormatTarkirBlock,
        "ktk block"                   => FormatTarkirBlock,
        "khans of tarkir block"       => FormatTarkirBlock,
        "battle for zendikar block"   => FormatBattleForZendikarBlock,
        "bfz block"                   => FormatBattleForZendikarBlock,
        "soi block"                   => FormatShadowsOverInnistradBlock,
        "shadows over innistrad block"=> FormatShadowsOverInnistradBlock,
        "kld block"                   => FormatKaladeshBlock,
        "kaladesh block"              => FormatKaladeshBlock,
        "unsets"                      => FormatUnsets,
        "un-sets"                     => FormatUnsets,
        "standard"                    => FormatStandard,
        "modern"                      => FormatModern,
        "frontier"                    => FormatFrontier,
        "legacy"                      => FormatLegacy,
        "vintage"                     => FormatVintage,
        "commander"                   => FormatCommander,
        "pauper"                      => FormatPauper,
        "duel commander"              => FormatDuelCommander,
        "penny dreadful"              => FormatPennyDreadful,
        "pd"                          => FormatPennyDreadful,
        "custom standard"             => FormatCustomStandard,
        "cstd"                        => FormatCustomStandard,
        "cs"                          => FormatCustomStandard,
        "custom eternal"              => FormatCustomEternal,
        "ce"                          => FormatCustomEternal,
        "custom commander"            => FormatCustomCommander,
        "custom edh"                  => FormatCustomCommander,
        "cc"                          => FormatCustomCommander,
        "cedh"                        => FormatCustomCommander,
      }
    end

    def all_format_classes
      formats_index.values.uniq
    end

    def [](format)
      formats_index[format] || FormatUnknown
    end
  end
end

require_relative "format_vintage"
require_relative "format_standard"
require_relative "format_custom_eternal"
Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end

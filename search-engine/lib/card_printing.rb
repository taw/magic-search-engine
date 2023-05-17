class CardPrinting
  attr_reader :card, :set, :date, :release_date
  attr_reader :watermark, :artist_name, :multiverseid, :number, :frame, :flavor, :flavor_normalized, :border
  attr_reader :rarity_code, :print_sheet, :oversized, :frame_effects, :foiling, :spotlight
  attr_reader :textless, :fullart, :buyabox, :flavor_name, :nontournament, :acorn
  attr_reader :attraction_lights, :promo_types, :variant_misprint, :variant_foreign, :signature, :subsets, :timeshifted
  attr_reader :stamp, :digital, :language, :etched

  # Performance cache of derived information
  attr_reader :stemmed_name, :set_code
  attr_reader :release_date_i, :number_i

  # Set by CardDatabase initialization
  attr_accessor :others, :artist, :default_sort_index, :partner, :in_boosters

  def initialize(card, set, data)
    @card = card
    @set = set
    @others = nil
    @release_date = data["release_date"] ? Date.parse(data["release_date"]) : @set.release_date
    @release_date_i = @release_date.to_i_sort
    @watermark = data["watermark"]
    @number = data["number"]
    @number_i = @number.to_i
    @multiverseid = data["multiverseid"]
    if data["artist"]
      @artist_name = data["artist"].normalize_accents # TODO: move to indexer
    else
      warn "Card #{card.name} in #{set.code} lacks artist"
      @artist_name = "Unknown"
    end
    @flavor = data["flavor"] || -""
    @flavor_name = data["flavor_name"]
    @flavor_normalized = @flavor.normalize_accents
    @foiling = data["foiling"]
    @border = data["border"] || @set.border
    @frame = data["frame"]
    @frame_effects = data["frame_effects"] || []
    rarity = data["rarity"]
    @rarity_code = %W[basic common uncommon rare mythic special].index(rarity) or raise "Unknown rarity #{rarity}"
    @acorn = data["acorn"]
    @arena = data["arena"]
    @attraction_lights = data["attraction_lights"]
    @buyabox = data["buyabox"]
    @digital = data["digital"]
    @etched = data["etched"]
    @exclude_from_boosters = data["exclude_from_boosters"]
    @fullart = data["fullart"]
    @language = data["language"]
    @mtgo = data["mtgo"]
    @nontournament = data["nontournament"]
    @others = data["others"] # overriden by CardDatabase
    @oversized = data["oversized"]
    @paper = data["paper"]
    @partner = data["partner"] # overriden by CardDatabase
    @print_sheet = data["print_sheet"]
    @promo_types = data["promo_types"]
    @shandalar = data["shandalar"]
    @signature = data["signature"]
    @spotlight = data["spotlight"]
    @stamp = data["stamp"]
    @subsets = data["subsets"]
    @textless = data["textless"]
    @timeshifted = data["timeshifted"]
    @variant_foreign = data["variant_foreign"]
    @variant_misprint = data["variant_misprint"]
    @xmage = data["xmage"]

    # Performance cache
    @stemmed_name = @card.stemmed_name
    @set_code = @set.code

    # Initialized after boosters are loaded
    @in_boosters = false
  end

  def arena?
    !!@arena
  end

  def paper?
    !!@paper
  end

  def mtgo?
    !!@mtgo
  end

  def shandalar?
    !!@shandalar
  end

  def xmage?
    !!@xmage
  end

  def in_boosters?
    @in_boosters
  end

  def rarity
    %W[basic common uncommon rare mythic special].fetch(@rarity_code)
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

  %W[block_code block_name online_only?].each do |m|
    eval("def #{m}; @set.#{m}; end")
  end
  %W[name names layout colors mana_cost reserved types cmc text text_normalized power
    toughness loyalty extra color_identity has_multiple_parts? typeline
    first_release_date last_release_date printings life hand rulings
    foreign_names foreign_names_normalized mana_hash funny color_indicator color_indicator_set
    related first_regular_release_date reminder_text augment
    display_power display_toughness display_mana_cost
    primary? secondary? front? back? partner? allowed_in_any_number?
    commander? brawler? custom? keywords
    count_sets count_prints count_papersets count_paperprints name_slug
    fulltext fulltext_normalized defense colors_set color_identity_set
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
    [name, set, number_i, number] <=> [other.name, other.set, other.number_i, other.number]
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

  def valid_partner_for?(other)
    return unless partner? and other.partner?
    if partner
      return false unless partner.name == other.name
    end
    if other.partner
      return false unless name == other.partner.name
    end
    true
  end

  def main_front
    physical_card.main_front
  end

  def physical_card
    PhysicalCard.for(self)
  end

  def foilonly?
    foiling == "foilonly"
  end

  def nonfoilonly?
    foiling == "nonfoil"
  end
end

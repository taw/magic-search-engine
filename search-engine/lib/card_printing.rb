class CardPrinting
  attr_reader :card, :set, :date, :release_date
  attr_reader :watermark, :rarity, :artist_name, :multiverseid, :number, :frame, :flavor, :flavor_normalized, :border, :timeshifted
  attr_reader :rarity_code, :print_sheet, :partner, :oversized

  # Performance cache of derived information
  attr_reader :stemmed_name, :set_code
  attr_reader :release_date_i

  # Set by CardDatabase initialization
  attr_accessor :others, :artist, :default_sort_index, :partner

  def initialize(card, set, data)
    @card = card
    @set = set
    @others = nil
    @release_date = data["release_date"] ? Date.parse(data["release_date"]) : @set.release_date
    @release_date_i = @release_date.to_i_sort
    @watermark = data["watermark"]
    @number = data["number"]
    @multiverseid = data["multiverseid"]
    @artist_name = data["artist"]
    @flavor = data["flavor"] || -""
    @flavor_normalized = @flavor.tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-")
    @flavor_normalized = @flavor if @flavor_normalized == @flavor # Memory saving trick
    @foiling = data["foiling"]
    @border = data["border"] || @set.border
    @frame = data["frame"] || @set.frame
    @timeshifted = data["timeshifted"] || false
    rarity = data["rarity"]
    @rarity_code = %W[basic common uncommon rare mythic special].index(rarity) or raise "Unknown rarity #{rarity}"
    @exclude_from_boosters = data["exclude_from_boosters"]
    @print_sheet = data["print_sheet"]
    @partner = data["partner"]
    @oversized = data["oversized"]

    # Performance cache
    @stemmed_name = @card.stemmed_name
    @set_code = @set.code
  end

  # "foilonly", "nonfoil", "both"
  def foiling
    return @foiling if @foiling
    case @set.foiling
    when "nonfoil", "foilonly", "both"
      @set.foiling
    when "booster_both"
      if in_boosters?
        "both"
      else
        foiling_in_precons
      end
    when "precon"
      foiling_in_precons
    else
      "#{@set.foiling} -> totally_unknown"
    end
  end

  # TODO: This could seriously move to indexer once deck index and primary index are merged
  private def foiling_in_precons
    raise "No #{set_code} cards in any precon deck" unless @set.cards_in_precons
    nonfoils, foils = @set.cards_in_precons
    has_nonfoil = nonfoils.include?(name)
    has_foil = foils.include?(name)

    if has_foil and has_nonfoil
      "precon with both, wat?"
    elsif has_nonfoil
      "nonfoil"
    elsif has_foil
      "foilonly"
    else
      "missing_from_precon"
    end
  end

  def in_boosters?
    (@set.has_boosters? or @set.in_other_boosters?) and !@exclude_from_boosters
  end

  def exclude_from_boosters?
    !!@exclude_from_boosters
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

  def set_type
    @set.type
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
    primary? secondary? front? back? partner?
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

  def magiccards_info_link
    "http://magiccards.info/#{set_code}/en/#{number}.html"
  end

  include Comparable
  def <=>(other)
    [name, set, number.to_i, number] <=> [other.name, other.set, other.number.to_i, other.number]
  end

  def age
    [0, (release_date - first_regular_release_date).to_i].max
  end

  def inspect
    "CardPrinting(#{name}, #{set_code})"
  end

  def id
    "#{set_code}/#{number}"
  end

  def to_s
    inspect
  end
end

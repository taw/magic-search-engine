class CardPrinting
  attr_reader :card, :set, :date, :release_date
  attr_reader :watermark, :rarity, :artist_name, :multiverseid, :number, :frame, :flavor, :border, :timeshifted, :printed_text, :printed_typeline
  attr_reader :rarity_code

  # Performance cache of derived information
  attr_reader :stemmed_name, :set_code
  attr_reader :release_date_i

  # Set by CardDatabase initialization
  attr_accessor :others, :artist, :default_sort_index

  def initialize(card, set, data)
    @card = card
    @set = set
    @others = nil
    @release_date = data["release_date"] ? Date.parse(data["release_date"]) : @set.release_date
    @release_date_i = @release_date.to_i_sort
    @watermark = data["watermark"]&.downcase
    @number = data["number"]
    @multiverseid = data["multiverseid"]
    @artist_name = data["artist"]
    @flavor = data["flavor"] || ""
    @border = data["border"] || @set.border
    @timeshifted = data["timeshifted"] || false
    @printed_text = (data["originalText"] || "").gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-")
    unless card.funny
      @printed_text = @printed_text.gsub(/\([^\(\)]*\)/, "")
    end
    @printed_typeline = data["originalType"] || ""
    rarity = data["rarity"]
    @rarity_code = %W[basic common uncommon rare mythic special].index(rarity) or raise "Unknown rarity #{rarity}"
    @frame = begin
      eight_edition_release_date = Date.new(2003,7,28)
      m15_release_date = Date.new(2014,7,18)
      if @release_date < eight_edition_release_date
        "old"
      elsif @set.code == "tsts"
        "old"
      elsif @timeshifted and @set.code == "fut"
        "future"
      elsif @release_date < m15_release_date
        # Were there any 8e+ old frame printings?
        "modern"
      else
        "m15"
      end
    end

    # Performance cache
    @stemmed_name = @card.stemmed_name
    @set_code = @set.code
  end

  def rarity
    %W[basic common uncommon rare mythic special].fetch(@rarity_code)
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
  %W[name names layout colors mana_cost reserved types cmc text power
    toughness loyalty extra color_identity has_multiple_parts? typeline
    first_release_date last_release_date printings life hand rulings
    secondary foreign_names foreign_names_normalized mana_hash funny color_indicator
    related first_regular_release_date reminder_text augment
    display_power display_toughness
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

  def to_s
    inspect
  end
end

class CardPrinting
  attr_reader :card, :set, :date, :release_date, :set_code
  attr_accessor :others, :artist

  def initialize(card, set, data)
    @card = card
    @set = set
    @set_code = @set.code # performance caching
    @data = data
    @others = nil
    @release_date = @data["release_date"] ? Date.parse(@data["release_date"]) : @set.release_date
  end

  def watermark
    @data["watermark"] && @data["watermark"].downcase
  end

  def number
    @data["number"]
  end

  def multiverseid
    @data["multiverseid"]
  end

  def artist_name
    @data["artist"]
  end

  def flavor
    @data["flavor"] || ""
  end

  def border
    @data["border"] || @set.border
  end

  def timeshifted
    @data["timeshifted"] || false
  end

  def year
    release_date && release_date.year
  end

  def rarity
    @data["rarity"]
  end

  def set_type
    @set.type
  end

  def frame
    @frame ||= begin
      eight_edition_release_date = Date.parse("2003-07-28")
      if @release_date < eight_edition_release_date
        "old"
      elsif set_code == "tsts"
        "old"
      elsif timeshifted and set_code == "fut"
        "future"
      else
        # Were there any 8e+ old frame printings?
        "new"
      end
    end
  end

  # This is a bit too performance-critical to use method_missing
  # It's not a huge difference, but no reason to waste ~5% of execution time on it
  def set_name
    @set.name
  end
  %W[block_code block_name].each do |m|
    eval("def #{m}; @set.#{m}; end")
  end
  %W[name names layout colors mana_cost reserved types cmc text power
    toughness loyalty extra color_identity has_multiple_parts? typeline
    first_release_date last_release_date printings life hand rulings
    secondary foreign_names stemmed_name legal_in_no_format
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
    [name, set, number] <=> [other.name, other.set, other.number]
  end

  def inspect
    "CardPrinting(#{name}, #{set_code})"
  end

  def to_s
    inspect
  end
end

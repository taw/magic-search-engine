class CardPrinting
  attr_reader :card, :set, :date, :release_date, :set_code
  attr_accessor :others

  def initialize(card, set, data)
    @card = card
    @set = set
    @set_code = @set.set_code # performance caching
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

  def artist
    @data["artist"].downcase
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

  def frame
    @frame ||= begin
      # Each promo needs to be manually checked
      old_border_sets = %w"al be an un ced cedi drc aq rv lg dk mbp fe dcilm 4e ia ch hl ai arena uqc mr mgbc itp vi 5e pot po wl ptc tp sh po2 jr ex ug apac us at ul 6e p3k ud st guru wrl wotc mm br sus fnmp euro ne st2k pr bd in ps 7e mprp ap od dm tr ju on le sc rep tsts"

      if timeshifted and set_code == "fut"
        "future"
      elsif old_border_sets.include?(set_code)
        "old"
      else
        "new"
      end
    end
  end

  # This is a bit too performance-critical to use method_missing
  # It's not a huge difference, but no reason to waste ~5% of execution time on it
  %W[set_name block_code block_name].each do |m|
    eval("def #{m}; @set.#{m}; end")
  end
  %W[name names layout colors mana_cost reserved types cmc text power
    toughness loyalty extra color_identity has_multiple_parts? typeline
    first_release_date last_release_date printings
  ].each do |m|
    eval("def #{m}; @card.#{m}; end")
  end

  def all_legalities(time=nil)
    @card.all_legalities(time)
  end


  include Comparable
  def <=>(other)
    [name, set, number] <=> [other.name, other.set, other.number]
  end

  def inspect
    "CardPrinting(#{card.name}, #{set.set_code})"
  end

  def to_s
    inspect
  end
end

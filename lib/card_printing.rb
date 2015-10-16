class CardPrinting
  attr_reader :card, :set, :date, :release_date
  attr_accessor :others

  def initialize(card, set, data)
    @card = card
    @set = set
    @data = data
    @others = nil
    @release_date = @data["release_date"] ? Date.parse(@data["release_date"]) : @set.release_date
  end

  def set_code
    @set.set_code
  end

  def set_name
    @set.set_name
  end

  def block_code
    @set.block_code
  end

  def block_name
    @set.block_name
  end

  def watermark
    @data["watermark"] && @data["watermark"].downcase
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

  def method_missing(m,*args)
    @card.send(m,*args)
  end

  include Comparable
  def <=>(other)
    [name, set] <=> [other.name, other.set]
  end

  def inspect
    "CardPrinting(#{card.name}, #{set.set_code})"
  end

  def to_s
    inspect
  end
end

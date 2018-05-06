# Ignoring marketing card
# FIXME: ignoring foils
class Pack
  def initialize(set, distribution)
    @set = set
    @distribution = distribution
    @pools = {}
  end

  def open
    cards = []
    @distribution.each do |category, count|
      cards.push *pool(category).sample(count)
    end
    cards
  end

  def pool(category)
    @pools[category] ||= begin
      case category
      when :basic, :common, :uncommon, :rare
        @set.printings.select{|c| c.rarity == category.to_s}
      when :rare_or_mythic
        # Rares 2x as frequent as mythics
        @set.printings.select{|c| c.rarity == "rare"} * 2 +
        @set.printings.select{|c| c.rarity == "mythic"}
      else
        raise "Unknown category #{category}"
      end
    end
  end

  def self.for(db, set_code)
    set = db.sets[set_code]
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize

    # https://mtg.gamepedia.com/Booster_pack
    case set_code
    when "7e", "8e", "9e", "10e"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare: 1})
    when "lw", "mt", "shm", "eve"
      Pack.new(set, {common: 11, uncommon: 3, rare: 1})
    # Default configuration before mythics
    # Back then there was no crazy variation
    when "mr", "vi",
      "tp", "sh", "ex",
      "us", "ul", "ud",
      "mm", "pr", "ne",
      "in", "ps", "ap",
      "od", "tr", "ju",
      "on", "le", "sc",
      "mi", "ds", "5dn",
      "chk", "bok", "sok",
      "rav", "gp", "di",
      "cs"
      Pack.new(set, {common: 11, uncommon: 3, rare: 1})
    # Default configuration since mythics got introduced
    # A lot of sets don't fit this
    when "m10", "m11", "m12", "m13", "m14", "m15",
      "ala", "cfx", "arb",
      "zen", "wwk", "roe",
      "som", "mbs", "nph",
      "avr",
      "rtr", "gtc",
      "ths", "bng", "jou",
      "ktk", "frf", "dtk"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1})
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end
  end
end

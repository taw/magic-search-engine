# Ignoring marketing/token card
class Pack
  attr_reader :has_random_foil, :has_guaranteed_foil, :distribution
  def initialize(set, distribution, has_random_foil: false, has_guaranteed_foil: false)
    @set = set
    @distribution = distribution
    @has_random_foil = has_random_foil
    @has_guaranteed_foil = has_guaranteed_foil
    @pools = {}
  end

  def open
    cards = []
    cards.push random_foil if @has_guaranteed_foil
    @distribution.each do |category, count|
      if category == :common and roll_for_foil
        cards.push *pool(category).sample(count - 1)
        cards.push random_foil
      else
        cards.push *pool(category).sample(count)
      end
    end
    cards
  end

  # Based on https://www.reddit.com/r/magicTCG/comments/snzvt/simple_avr_sealed_simulator_i_just_made/c4fk0sr/
  # Details probably vary by set and I don't have too much trust in any of these numbers anyway
  def roll_for_foil
    @has_random_foil and rand < 0.25
  end

  def random_foil
    i = rand(16)
    if i == 0
      pool(:rare_or_mythic).sample
    elsif i == 1
      pool(:basic_fallover_to_common).sample
    elsif i <= 4
      pool(:uncommon).sample
    else
      pool(:common).sample
    end
  end

  def physical_cards
    @set.printings.select do |card|
      next true unless card.has_multiple_parts?
      next !card.secondary if card.layout == "flip"
      next (card.number =~ /a/) if card.layout == "split"
      next true if card.name == "B.F.M. (Big Furry Monster)"
      next true if card.name == "B.F.M. (Big Furry Monster, Right Side)"
      raise "Not sure if #{card.name} is a physical card"
    end
  end

  def pool(category)
    @pools[category] ||= begin
      case category
      when :basic, :common, :uncommon, :rare
        physical_cards.select{|c| c.rarity == category.to_s}
      # Rares 2x as frequent as mythics
      when :rare_or_mythic
        physical_cards.select{|c| c.rarity == "rare"} * 2 +
        physical_cards.select{|c| c.rarity == "mythic"}
      # In old sets commons and basics were printed on shared sheet
      when :common_or_basic
        physical_cards.select{|c| c.rarity == "common"} +
        physical_cards.select{|c| c.rarity == "basic"}
      # for foils
      when :basic_fallover_to_common
        if pool(:basic).empty?
          pool(:common)
        else
          pool(:basic)
        end
      else
        raise "Unknown category #{category}"
      end
    end
  end

  def pool_size(category)
    pool(category).uniq.size
  end

  def cards_in_nonfoil_pools
    distribution.keys.flat_map{|k| pool(k)}.uniq
  end

  def self.for(db, set_code)
    set = db.sets[set_code.downcase]
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize

    # https://mtg.gamepedia.com/Booster_pack
    case set_code
    when "ug"
      Pack.new(set, {basic: 1, common: 6, uncommon: 2, rare: 1})
    when "ai", "ch"
      Pack.new(set, {common: 8, uncommon: 3, rare: 1})
    when "7e", "8e", "9e", "10e"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare: 1}, has_random_foil: true)
    when "lw", "mt", "shm", "eve"
      Pack.new(set, {common_or_basic: 11, uncommon: 3, rare: 1}, has_random_foil: true)
    # Default configuration before mythics
    # Back then there was no crazy variation
    # 6ed came out after foils started, but didn't have foils
    when "5e", "6e",
      "mr", "vi", "wl",
      "tp", "sh", "ex",
      "us"
      Pack.new(set, {common_or_basic: 11, uncommon: 3, rare: 1})
    # Pre-mythic, with foils
    when "ul", "ud",
      "mm", "pr", "ne",
      "in", "ps", "ap",
      "od", "tr", "ju",
      "on", "le", "sc",
      "mi", "ds", "5dn",
      "chk", "bok", "sok",
      "rav", "gp", "di",
      "cs"
      Pack.new(set, {common_or_basic: 11, uncommon: 3, rare: 1}, has_random_foil: true)
    # Default configuration since mythics got introduced
    # A lot of sets don't fit this
    when "m10", "m11", "m12", "m13", "m14", "m15",
      "ala", "cfx", "arb",
      "zen", "wwk", "roe",
      "som", "mbs", "nph",
      "avr",
      "rtr", "gtc",
      "ths", "bng", "jou",
      "ktk", "frf", "dtk",
      "tpr"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1}, has_random_foil: true)
    when "mma", "mm2", "mm3", "ema", "ima", "a25"
      Pack.new(set, {common: 10, uncommon: 3, rare_or_mythic: 1}, has_guaranteed_foil: true)
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end
  end
end

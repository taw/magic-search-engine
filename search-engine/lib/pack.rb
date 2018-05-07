# Ignoring marketing/token card
class Pack
  attr_reader :has_random_foil, :has_guaranteed_foil, :distribution, :masterpieces
  def initialize(set, distribution, has_random_foil: false, has_guaranteed_foil: false, masterpieces: nil, common_if_no_basic: false)
    @set = set
    @distribution = distribution.dup
    @has_random_foil = has_random_foil
    @has_guaranteed_foil = has_guaranteed_foil
    @masterpieces = masterpieces
    @sheets = {}
    # Small sets often have no basic lands
    if common_if_no_basic and !sheet(:basic)
      @distribution[:common] += @distribution.delete(:basic)
    end
  end

  def open
    cards = []
    cards.push random_foil if @has_guaranteed_foil
    @distribution.each do |category, count|
      if category == :common and roll_for_foil
        cards.push random_foil
        count -= 1
      end
      cards.push *sheet(category).random_cards_without_duplicates(count)
    end
    cards
  end

  # Based on https://www.reddit.com/r/magicTCG/comments/snzvt/simple_avr_sealed_simulator_i_just_made/c4fk0sr/
  # Details probably vary by set and I don't have too much trust in any of these numbers anyway
  def roll_for_foil
    @has_random_foil and rand < 0.25
  end

  # Wo don't have anywhere near reliable information
  # Masterpieces supposedly are in 1/144 booster (then 1/129 for Amonkhet)
  #
  # Let's just assume they replace common foils
  #
  # These numbers could be totally wrong
  def random_foil
    i = rand(36)
    if i < 8
      sheet(:foil_rare_or_mythic).random_card
    elsif i < 16
      sheet(:foil_basic_fallover_to_common).random_card
    elsif i < 32
      sheet(:foil_uncommon).random_card
    elsif i < 36 and @masterpieces
      # This is 1:128, so more like Amonkhet odds
      @masterpieces.random_card
    else
      sheet(:foil_common).random_card
    end
  end

  def sheet(category)
    @sheets[category] ||= begin
      case category
      when :basic, :common, :uncommon, :rare
        CardSheet.rarity(@set, category.to_s)
      when :foil_basic, :foil_common, :foil_uncommon, :foil_rare
        CardSheet.rarity(@set, category.to_s.sub(/\Afoil_/, ""), foil: true)
      when :rare_or_mythic
        CardSheet.rare_or_mythic(@set)
      when :foil_rare_or_mythic
        CardSheet.rare_or_mythic(@set, foil: true)
      # In old sets commons and basics were printed on shared sheet
      when :common_or_basic
        CardSheet.common_or_basic(@set)
      # for foils
      when :foil_basic_fallover_to_common
        if !sheet(:basic)
          sheet(:common)
        else
          sheet(:basic)
        end
      else
        raise "Unknown category #{category}"
      end
    end
  end

  def cards_on_nonfoil_sheets
    distribution.keys.flat_map{|k| sheet(k).cards}
  end

  def number_of_cards_on_nonfoil_sheets
    cards_on_nonfoil_sheets.size
  end

  def self.for(db, set_code)
    set = db.resolve_edition(set_code)
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize

    # https://mtg.gamepedia.com/Booster_pack
    case set_code
    when "p3k"
      Pack.new(set, {basic: 2, common: 5, uncommon: 2, rare: 1})
    when "st"
      Pack.new(set, {basic: 2, common: 9, uncommon: 3, rare: 1})
    when "ug"
      Pack.new(set, {basic: 1, common: 6, uncommon: 2, rare: 1})
    when "ai", "ch"
      # FIXME: These are not correct numbers
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
      "us",
      "po", "po2"
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
      "tpr", "med", "me2", "me3", "me4",
      # They have DFCs but no separate slot for DFCs
      "ori", "xln", "rix",
      # there's guaranteed legendary, but no separate slots, unclear how to model that
      # If we don't model anything, there's 81% chance of opening a legendary, and EV of 1.34
      "dom"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1}, has_random_foil: true, common_if_no_basic: true)
    when "mma", "mm2", "mm3", "ema", "ima", "a25"
      Pack.new(set, {common: 10, uncommon: 3, rare_or_mythic: 1}, has_guaranteed_foil: true)
    when "bfz", "ogw", "kld", "aer", "akh", "hou"
      Pack.new(set,
        {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1},
        has_random_foil: true,
        common_if_no_basic: true,
        masterpieces: CardSheet.masterpieces_for(db, set_code))
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end
  end
end

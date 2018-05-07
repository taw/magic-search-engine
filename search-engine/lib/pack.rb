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
      when :u3u2
        CardSheet.u3u2(@set)
      when :u3u1
        CardSheet.u3u1(@set)
      when :u2u1
        CardSheet.u2u1(@set)
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
    when "7e", "8e", "9e", "10e", "uh"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare: 1}, has_random_foil: true)
    when "lw", "mt", "shm", "eve"
      Pack.new(set, {common_or_basic: 11, uncommon: 3, rare: 1}, has_random_foil: true)
    # Default configuration before mythics
    # Back then there was no crazy variation
    # 6ed came out after foils started, but didn't have foils
    when "4e", "5e", "6e",
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
      "ktk", "dtk",
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
    # These are just approximations, they actually used nonstandard sheets
    when "al", "be", "un", "rv", "ia"
      Pack.new(set, {common_or_basic: 11, uncommon: 3, rare: 1})
    when "ai", "ch"
      Pack.new(set, {common: 8, uncommon: 3, rare: 1})
    when "aq"
      # Antiquities was printed on sheets of 121 cards. The expansion symbol is an anvil,
      # to symbolize the artifact focus of the set. [2] The set's rarity breakdown is:
      # 28 commons (25@C4, 1@C5, 2@C6), 37 Uncommons (4@U2, 29@U3, 2@C1, 2@(U3+C1)), 20 Rares (20@U1).
      # This strange distribution comes from the lands Mishra's Factory, Strip Mine, Urza's Mine,
      # Urza's Power Plant and Urza's Tower which have four different pieces of art each.
      # Mishra's Factory and Strip Mine have three versions at U1 and one at C1.
      # Urza's Mine and Urza's Power Plant have two versions at C1 and two at C2.
      # Urza's Tower has three versions at C1 and one at C2.
      # This makes it so collectors view Antiquities as as 100-card set.
      #
      # Simplify it to C4, U3 U1
      Pack.new(set, {common: 6, u3u1: 2})
    when "an"
      # The set's rarity breakdown is: 26 commons (1@C11, 9@C5, 16@C4) and 52 uncommons (1@C1, 1@U4, 17@U3, 33@U2).
      # Simplify it to C4 U3 U2 only
      Pack.new(set, {common: 6, u3u2: 2})
    when "dk"
      # The Dark was printed on sheets of 121 cards and contains 119 unique cards total.
      # The set's rarity breakdown is: 40 commons (40@C3), 1 Uncommon (1@C1), 78 Rares (35@U1, 43@U2).
      #
      # It's actually modelled as 40 commons, 44 uncommons, 35 rares
      # We'll simplify to C3, U2 U1
      Pack.new(set, {common: 6, u2u1: 2})
    when "fe"
      # The set's rarity breakdown is: 35 commons (15@C4, 20@C3), 31 Uncommons (25@U3, 5@U2, 1@C1), 36 Rares (36@U1).
      #
      # Simplify to C3, U3 U1
      Pack.new(set, {common: 6, u3u1: 2})
    when "hl"
      # The set's rarity breakdown is: 25 commons (25@C4), 47 Uncommons (26@U3, 21@C1), 43 Rares (43@U1).
      #
      # Simplify to C4, U3 U1
      Pack.new(set, {common: 6, u3u1: 2})
    when "lg"
      # The set's rarity breakdown is: 75 commons (29@C1, 46@C2), 114 Uncommons (107@U1, 7@U2), 121 Rares.
      #
      # Simplify to C1, U1, R1
      Pack.new(set, {common: 12, uncommon: 3, rare: 1})
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end
  end
end

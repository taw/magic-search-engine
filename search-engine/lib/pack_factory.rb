class PackFactory
  def initialize(db)
    @db = db
    @sheet_factory = CardSheetFactory.new(@db)
  end

  def inspect
    "#{self.class}"
  end

  # This is a bit of a mess
  private def build_pack(set_code, distribution, has_random_foil: false, common_if_no_basic: false)
    # Based on https://www.reddit.com/r/magicTCG/comments/snzvt/simple_avr_sealed_simulator_i_just_made/c4fk0sr/
    # Details probably vary by set and I don't have too much trust in any of these numbers anyway
    if has_random_foil
      if distribution[:common]
        foil_distribution = distribution.merge({foil: 1, common: distribution[:common] - 1})
      elsif
        foil_distribution = distribution.merge({foil: 1, common_or_basic: distribution[:common_or_basic] - 1})
      else
        raise "Foil requested, but not sure which slot to replace: #{distribution}"
      end
      normal_pack = build_pack(set_code, distribution, common_if_no_basic: common_if_no_basic)
      foil_pack = build_pack(set_code, foil_distribution, common_if_no_basic: common_if_no_basic)
      return WeightedPack.new({normal_pack => 3, foil_pack => 1})
    end

    # This awkwardness is for common_if_no_basic logic
    sheets = {}
    distribution.each do |name, weight|
      sheets[name] = build_sheet(set_code, name)
    end
    if common_if_no_basic and !sheets[:basic]
      distribution = distribution.dup
      distribution[:common] += distribution.delete(:basic)
    end
    Pack.new(distribution.map{|n,w| [sheets[n], w]}.to_h)
  end

  private def build_sheet(set_code, name)
    case name
    when :basic, :common, :uncommon, :rare
      @sheet_factory.rarity(set_code, name.to_s)
    when :rare_or_mythic
      @sheet_factory.rare_or_mythic(set_code)
    # In old sets commons and basics were printed on shared sheet
    when :common_or_basic
      @sheet_factory.common_or_basic(set_code)
    when :foil
      @sheet_factory.foil_sheet(set_code)
    # Various old sheets
    when :u3u2, :u3u1, :u2u1, :sfc_common, :sfc_uncommon, :sfc_rare_or_mythic
      @sheet_factory.send(name, set_code)
    # Various special sheets
    when :dgm_land, :frf_land, :dgm_common, :frf_common, :dgm_rare_mythic, :unhinged_foil, :theros_gods,
         :isd_dfc, :dka_dfc, :tsts, :ts_foil,
         :pc_common, :pc_uncommon, :pc_rare, :pc_cs_common, :pc_cs_uncommon_rare,
         :vma_special, :soi_dfc_common_uncommon, :soi_dfc_rare_mythic
      @sheet_factory.send(name)
    else
      raise "Unknown sheet type #{name}"
    end
  end

  def for(set_code)
    set = @db.resolve_edition(set_code)
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize

    # https://mtg.gamepedia.com/Booster_pack
    case set_code
    when "p3k"
      build_pack(set_code, {basic: 2, common: 5, uncommon: 2, rare: 1})
    when "st"
      build_pack(set_code, {basic: 2, common: 9, uncommon: 3, rare: 1})
    when "ug"
      build_pack(set_code, {basic: 1, common: 6, uncommon: 2, rare: 1})
    when "7e", "8e", "9e", "10e"
      build_pack(set_code, {basic: 1, common: 10, uncommon: 3, rare: 1}, has_random_foil: true)
    # Default configuration before mythics
    # Back then there was no crazy variation
    # 6ed came out after foils started, but didn't have foils
    when "4e", "5e", "6e",
      "mr", "vi", "wl",
      "tp", "sh", "ex",
      "us",
      "po", "po2"
      build_pack(set_code, {common_or_basic: 11, uncommon: 3, rare: 1})
    # Pre-mythic, with foils
    when "ul", "ud",
      "mm", "pr", "ne",
      "in", "ps", "ap",
      "od", "tr", "ju",
      "on", "le", "sc",
      "mi", "ds", "5dn",
      "chk", "bok", "sok",
      "rav", "gp", "di",
      "cs",
      "fut", # Amazingly Future Sight has regular boring sheets
      "lw", "mt", "shm", "eve"
      build_pack(set_code, {common_or_basic: 11, uncommon: 3, rare: 1}, has_random_foil: true)
    # Default configuration since mythics got introduced
    # A lot of sets don't fit this
    when "m10", "m11", "m12", "m13", "m14", "m15",
      "ala", "cfx", "arb",
      "zen", "wwk", "roe",
      "som", "mbs", "nph",
      "avr",
      "rtr", "gtc",
      "ths", "bng",
      "ktk", "dtk",
      "tpr", "med", "me2", "me3", "me4",
      # They have DFCs but no separate slot for DFCs
      "ori", "xln", "rix",
      # there's guaranteed legendary, but no separate slots, unclear how to model that
      # If we don't model anything, there's 81% chance of opening a legendary, and EV of 1.34
      "dom",
      # CardSheetFactory is aware that mastrepieces go onto foil sheet, wo don't need to do anything
      "bfz", "ogw",
      "kld", "aer",
      "akh", "hou"
      build_pack(set_code, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1}, has_random_foil: true, common_if_no_basic: true)
    when "mma", "mm2", "mm3", "ema", "ima", "a25"
      build_pack(set_code, {common: 10, uncommon: 3, rare_or_mythic: 1, foil: 1})
    when "dgm"
      WeightedPack.new(
        build_pack(set_code, {dgm_common: 10, uncommon: 3, dgm_rare_mythic: 1, dgm_land: 1}) => 3,
        build_pack(set_code, {dgm_common: 9, uncommon: 3, dgm_rare_mythic: 1, dgm_land: 1, foil: 1}) => 1,
      )
    when "frf"
      WeightedPack.new(
        build_pack(set_code, {frf_common: 10, uncommon: 3, rare_or_mythic: 1, frf_land: 1}) => 3,
        build_pack(set_code, {frf_common: 9, uncommon: 3, rare_or_mythic: 1, frf_land: 1, foil: 1}) => 1,
      )
    when "uh"
      WeightedPack.new(
        build_pack(set_code, {common: 10, uncommon: 3, rare_or_mythic: 1, basic: 1}) => 3,
        build_pack(set_code, {common: 9, uncommon: 3, rare_or_mythic: 1, basic: 1, unhinged_foil: 1}) => 1
      )
    when "jou"
      WeightedPack.new(
        build_pack(set_code, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1}, has_random_foil: true, common_if_no_basic: true) => 4319,
        build_pack(set_code, {theros_gods: 15}) => 1,
      )
    when "isd"
      WeightedPack.new(
        build_pack(set_code, {isd_dfc: 1, basic: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_or_mythic: 1}) => 3,
        build_pack(set_code, {isd_dfc: 1, basic: 1, sfc_common: 8, sfc_uncommon: 3, sfc_rare_or_mythic: 1, foil: 1}) => 1,
      )
    when "dka"
      WeightedPack.new(
        build_pack(set_code, {dka_dfc: 1, sfc_common: 10, sfc_uncommon: 3, sfc_rare_or_mythic: 1}) => 3,
        build_pack(set_code, {dka_dfc: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_or_mythic: 1, foil: 1}) => 1,
      )
    when "ts"
      # 10 commons, 3 uncommons, 1 rare, and 1 purple-rarity timeshifted card.
      # Basics don't fit anywhere
      WeightedPack.new(
        build_pack(set_code, {common: 10, uncommon: 3, rare: 1, tsts: 1}) => 3,
        build_pack(set_code, {common: 9, uncommon: 3, rare: 1, tsts: 1, ts_foil: 1}) => 1,
      )
    when "pc"
      # 8 commons, 2 uncommons, 1 rare, 3 timeshifted commons, and 1 uncommon or rare timeshifted card.s
      WeightedPack.new(
        build_pack(set_code, {pc_common: 8, pc_uncommon: 2, pc_rare: 1, pc_cs_common: 3, pc_cs_uncommon_rare: 1}) => 3,
        build_pack(set_code, {pc_common: 7, pc_uncommon: 2, pc_rare: 1, pc_cs_common: 3, pc_cs_uncommon_rare: 1, foil: 1}) => 1,
      )
    when "vma"
      build_pack(set_code, {common: 10, uncommon: 3, rare_or_mythic: 1, vma_special: 1})
    when "soi"
      # Assume foil rate (1:4) and rare/mythic dfc rates (1:8) are independent
      # They probably aren't
      WeightedPack.new(
        build_pack(set_code, {basic: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_or_mythic: 1, soi_dfc_common_uncommon: 1}) => 32-3-7-1,
        build_pack(set_code, {basic: 1, sfc_common: 8, sfc_uncommon: 3, sfc_rare_or_mythic: 1, soi_dfc_common_uncommon: 1, soi_dfc_rare_mythic: 1}) => 3,
        build_pack(set_code, {basic: 1, sfc_common: 8, sfc_uncommon: 3, sfc_rare_or_mythic: 1, soi_dfc_common_uncommon: 1, foil: 1}) => 7,
        build_pack(set_code, {basic: 1, sfc_common: 7, sfc_uncommon: 3, sfc_rare_or_mythic: 1, soi_dfc_common_uncommon: 1, soi_dfc_rare_mythic: 1, foil: 1}) => 1,
      )
    # These are just approximations, they actually used nonstandard sheets
    when "al", "be", "un", "rv", "ia"
      build_pack(set_code, {common_or_basic: 11, uncommon: 3, rare: 1})
    when "ai", "ch"
      build_pack(set_code, {common: 8, uncommon: 3, rare: 1})
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
      build_pack(set_code, {common: 6, u3u1: 2})
    when "an"
      # The set's rarity breakdown is: 26 commons (1@C11, 9@C5, 16@C4) and 52 uncommons (1@C1, 1@U4, 17@U3, 33@U2).
      # Simplify it to C4 U3 U2 only
      build_pack(set_code, {common: 6, u3u2: 2})
    when "dk"
      # The Dark was printed on sheets of 121 cards and contains 119 unique cards total.
      # The set's rarity breakdown is: 40 commons (40@C3), 1 Uncommon (1@C1), 78 Rares (35@U1, 43@U2).
      #
      # It's actually modelled as 40 commons, 44 uncommons, 35 rares
      # We'll simplify to C3, U2 U1
      build_pack(set_code, {common: 6, u2u1: 2})
    when "fe"
      # The set's rarity breakdown is: 35 commons (15@C4, 20@C3), 31 Uncommons (25@U3, 5@U2, 1@C1), 36 Rares (36@U1).
      #
      # Simplify to C3, U3 U1
      build_pack(set_code, {common: 6, u3u1: 2})
    when "hl"
      # The set's rarity breakdown is: 25 commons (25@C4), 47 Uncommons (26@U3, 21@C1), 43 Rares (43@U1).
      #
      # Simplify to C4, U3 U1
      build_pack(set_code, {common: 6, u3u1: 2})
    when "lg"
      # The set's rarity breakdown is: 75 commons (29@C1, 46@C2), 114 Uncommons (107@U1, 7@U2), 121 Rares.
      #
      # Simplify to C1, U1, R1
      build_pack(set_code, {common: 12, uncommon: 3, rare: 1})
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end
  end
end

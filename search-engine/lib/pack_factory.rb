class PackFactory
  def initialize(db)
    @db = db
    @sheet_factory = CardSheetFactory.new(@db)
  end

  def inspect
    "#{self.class}"
  end

  private def build_pack(set_code, distribution, common_if_no_basic: false)
    # This awkwardness is for common_if_no_basic logic
    sheets = {}
    distribution.each do |name, weight|
      sheets[name] = build_sheet(set_code, name)
    end
    if common_if_no_basic and !sheets[:basic]
      distribution = distribution.dup
      distribution[:common] += distribution.delete(:basic)
    end
    Pack.new(distribution.map{|name, weight|
      sheet = sheets[name] or raise "Can't build sheet #{name} for #{set_code}"
      [sheet, weight]
    }.to_h)
  end

  private def build_pack_with_random_foil(set_code, foil_sheet, replacement_sheet, distribution, common_if_no_basic: false)
    # Based on https://www.reddit.com/r/magicTCG/comments/snzvt/simple_avr_sealed_simulator_i_just_made/c4fk0sr/
    # Details probably vary by set and I don't have too much trust in any of these numbers anyway
    foil_distribution = distribution.dup
    raise "Foil requested, but not sure which slot to replace" if foil_distribution[foil_sheet]
    raise "Foil requested, but not sure which slot to replace" unless foil_distribution[replacement_sheet]
    foil_distribution[replacement_sheet] -= 1
    foil_distribution[foil_sheet] = 1

    normal_pack = build_pack(set_code, distribution, common_if_no_basic: common_if_no_basic)
    foil_pack = build_pack(set_code, foil_distribution, common_if_no_basic: common_if_no_basic)
    return WeightedPack.new({normal_pack => 3, foil_pack => 1})
  end

  private def build_sheet(set_code, name)
    case name
    when :common
      @sheet_factory.rarity(set_code, name.to_s, kind: ColorBalancedCardSheet)
    when :common_unbalanced
      @sheet_factory.rarity(set_code, "common")
    when :basic, :uncommon, :rare
      @sheet_factory.rarity(set_code, name.to_s)
    when :rare_or_mythic
      @sheet_factory.rare_or_mythic(set_code)
    # In old sets commons and basics were printed on shared sheet
    when :common_or_basic
      @sheet_factory.common_or_basic(set_code)
    when :common_or_basic_unbalanced
      @sheet_factory.common_or_basic(set_code, kind: CardSheet)
    when :foil
      @sheet_factory.foil_sheet(set_code)
    # Various old sheets
    when :explicit_common, :explicit_uncommon, :explicit_rare, :sfc_common, :sfc_uncommon, :sfc_rare_or_mythic
      @sheet_factory.send(name, set_code)
    # Various special sheets
    else
      if @sheet_factory.respond_to?(name)
        @sheet_factory.send(name)
      else
        raise "Unknown sheet type #{name}"
      end
    end
  end

  def for(set_code)
    set = @db.resolve_edition(set_code)
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize

    # https://mtg.gamepedia.com/Booster_pack
    case set_code
    when "ptk"
      build_pack(set_code, {basic: 2, common: 5, uncommon: 2, rare: 1})
    when "s99"
      build_pack(set_code, {basic: 2, common: 9, uncommon: 3, rare: 1})
    when "ugl"
      build_pack(set_code, {basic: 1, common_unbalanced: 6, uncommon: 2, rare: 1})
    when "7ed", "8ed", "9ed", "10e"
      build_pack_with_random_foil(set_code, :foil, :common, {basic: 1, common: 10, uncommon: 3, rare: 1})
    # Default configuration before mythics
    # Back then there was no crazy variation
    # 6ed came out after foils started, but didn't have foils
    when "4ed", "5ed", "6ed",
      "mir", "vis", "wth",
      "tmp", "sth", "exo",
      "usg",
      "por", "p02"
      build_pack(set_code, {common_or_basic: 11, uncommon: 3, rare: 1})
    # Pre-mythic, with foils
    when "ulg", "uds",
      "mmq", "pcy", "nem",
      "inv", "pls",
      "ody", "tor",
      "ons", "lgn", "scg",
      "mrd", "dst", "5dn",
      "chk", "bok", "sok",
      "csp",
      "fut", # Amazingly Future Sight has regular boring sheets
      "lrw", "mor"
      build_pack_with_random_foil(set_code, :foil, :common_or_basic, {common_or_basic: 11, uncommon: 3, rare: 1})
    # Don't try to color balance them
    # (APC should probably be balanced, just by c: not ci:)
    when "apc",
      "jud",
      "rav", "gpt", "dis",
      "shm", "eve"
      build_pack_with_random_foil(set_code, :foil, :common_or_basic_unbalanced, {common_or_basic_unbalanced: 11, uncommon: 3, rare: 1})
    # Default configuration since mythics got introduced
    # A lot of sets don't fit this
    when "m10", "m11", "m12", "m13", "m14", "m15",
      "ala", "con",
      "zen", "wwk", "roe",
      "som", "mbs", "nph",
      "avr",
      "rtr", "gtc",
      "ths", "bng",
      "ktk", "dtk",
      "tpr", "me1", "me2", "me3", "me4",
      # They have DFCs but no separate slot for DFCs
      "ori", "xln", "rix",
      # CardSheetFactory is aware that mastrepieces go onto foil sheet, wo don't need to do anything
      "bfz", "ogw",
      "kld", "aer",
      "akh", "hou",
      "m19"
      build_pack_with_random_foil(set_code, :foil, :common, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1}, common_if_no_basic: true)
    when "arb"
      build_pack_with_random_foil(set_code, :foil, :common_unbalanced, {common_unbalanced: 11, uncommon: 3, rare_or_mythic: 1})
    when "mma", "mm2", "mm3", "ema", "ima", "a25", "uma"
      build_pack(set_code, {common: 10, uncommon: 3, rare_or_mythic: 1, foil: 1})
    when "dgm"
      build_pack_with_random_foil(set_code, :foil, :dgm_common, {dgm_common: 10, uncommon: 3, dgm_rare_mythic: 1, dgm_land: 1})
    when "frf"
      build_pack_with_random_foil(set_code, :foil, :frf_common, {frf_common: 10, uncommon: 3, rare_or_mythic: 1, frf_land: 1})
    when "unh"
      build_pack_with_random_foil(set_code, :unhinged_foil, :common, {common: 10, uncommon: 3, rare_or_mythic: 1, basic: 1})
    when "jou"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, :foil, :common, {common: 11, uncommon: 3, rare_or_mythic: 1}) => 4319,
        build_pack(set_code, {theros_gods: 15}) => 1,
      )
    when "isd"
      build_pack_with_random_foil(set_code, :foil, :sfc_common, {isd_dfc: 1, basic: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_or_mythic: 1})
    when "dka"
      build_pack_with_random_foil(set_code, :foil, :sfc_common, {dka_dfc: 1, sfc_common: 10, sfc_uncommon: 3, sfc_rare_or_mythic: 1})
    when "tsp"
      # 10 commons, 3 uncommons, 1 rare, and 1 purple-rarity timeshifted card.
      # Basics don't fit anywhere
      build_pack_with_random_foil(set_code, :ts_foil, :common, {common: 10, uncommon: 3, rare: 1, tsts: 1})
    when "plc"
      # 8 commons, 2 uncommons, 1 rare, 3 timeshifted commons, and 1 uncommon or rare timeshifted card.
      build_pack_with_random_foil(set_code, :foil, :pc_common, {pc_common: 8, pc_uncommon: 2, pc_rare: 1, pc_cs_common: 3, pc_cs_uncommon_rare: 1})
    when "vma"
      build_pack(set_code, {common: 10, uncommon: 3, rare_or_mythic: 1, vma_special: 1})
    when "soi"
      # Assume foil rate (1:4) and rare/mythic dfc rates (1:8) are independent
      # They probably aren't
      WeightedPack.new(
        build_pack_with_random_foil(set_code, :foil, :sfc_common, {basic: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_or_mythic: 1, soi_dfc_common_uncommon: 1}) => 7,
        build_pack_with_random_foil(set_code, :foil, :sfc_common, {basic: 1, sfc_common: 8, sfc_uncommon: 3, sfc_rare_or_mythic: 1, soi_dfc_common_uncommon: 1, soi_dfc_rare_mythic: 1}) => 1,
      )
    when "emn"
      # Same assumptions as SOI, except no basics in the set
      WeightedPack.new(
        build_pack_with_random_foil(set_code, :foil, :sfc_common, {sfc_common: 10, sfc_uncommon: 3, sfc_rare_or_mythic: 1, emn_dfc_common_uncommon: 1}) => 7,
        build_pack_with_random_foil(set_code, :foil, :sfc_common, {sfc_common: 9, sfc_uncommon: 3, sfc_rare_or_mythic: 1, emn_dfc_common_uncommon: 1, emn_dfc_rare_mythic: 1}) => 1,
      )
    when "cns"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, :cns_nondraft_foil, :cns_nondraft_common, {cns_draft: 1, cns_nondraft_common: 10, cns_nondraft_uncommon: 3, cns_nondraft_rare_or_mythic: 1}) => 39,
        build_pack_with_random_foil(set_code, :cns_nondraft_foil, :cns_nondraft_common, {cns_draft_foil: 1, cns_nondraft_common: 10, cns_nondraft_uncommon: 3, cns_nondraft_rare_or_mythic: 1}) => 1,
      )
    when "bbd"
      # I ran the math, and best numbers are totally weird, so some rounded:
      # 1/4 have normal foil (very close to usual packs)
      # 1/10 have partner rare/mythig (exact)
      # 2/10 have partner uncommon (off by 12%)
      # 1/100 has partner foil (who knows really)

      WeightedPack.new(
        # No partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 3, bbd_rare_mythic: 1})             => 7 * 30 - 40,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 3, bbd_rare_mythic: 1}) => 7 * 10,
        # Uncommon partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 1, bbd_uncommon_partner: 2, bbd_rare_mythic: 1})             => 2 * 30,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 1, bbd_uncommon_partner: 2, bbd_rare_mythic: 1}) => 2 * 10,
        # Rare partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_rare_mythic_partner: 2})             => 1 * 30,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_rare_mythic_partner: 2}) => 1 * 10,
        # Foil partner
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_partner: 2, bbd_rare_mythic: 1}) => 4,
      )
    when "dom"
      # there's guaranteed legendary creature, but no separate slots for that
      # If we don't model anything, there's 71% chance of opening a legendary creature, and EV of 1.45
      #
      # Here's a simple model:
      # * all cards of same rarity equally frequent
      # * you'll get legend in every pack
      # * if rares/mythics is not legend, you get exactly 1 legend uncommon
      # * if rares/mythics is legend, you might get 0 or 1 legend uncommon
      # * foil work as in every other set
      #
      # I suspect there's a chance to get 2 or 3 legend uncommons in a pack
      # (9/64 and 1/64 if DOM was a regular set), so we could add more cases
      # and adjus numbers accordingly
      WeightedPack.new(
        build_pack_with_random_foil(set_code, :foil, :common, {basic: 1, common: 10, dom_nonlegendary_uncommon: 3, dom_legendary_rare_mythic: 1}) => 36*(144-23),
        build_pack_with_random_foil(set_code, :foil, :common, {basic: 1, common: 10, dom_nonlegendary_uncommon: 2, dom_legendary_uncommon: 1, dom_legendary_rare_mythic: 1}) => 36*23,
        build_pack_with_random_foil(set_code, :foil, :common, {basic: 1, common: 10, dom_nonlegendary_uncommon: 2, dom_legendary_uncommon: 1, dom_nonlegendary_rare_mythic: 1}) => (121-36)*144,
      )
    # To fully balance it like DOM, probabilities of double walker pack are negative!
    # If we disallow double planeswalker packs (rare pw and uncommon pw in same pack),
    # probabilities turn into almost perfect but not quite so values 1/1936 and 1/5808 deviation
    #
    # We can make this deviation go on rares on uncommons, either way it's too tiny to notice
    when "war"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, :war_foil, :common, {basic: 1, common: 10, war_nonplaneswalker_uncommon: 3, war_planeswalker_rare_mythic: 1}) => 29,
        build_pack_with_random_foil(set_code, :war_foil, :common, {basic: 1, common: 10, war_nonplaneswalker_uncommon: 2, war_planeswalker_uncommon: 1, war_nonplaneswalker_rare_mythic: 1}) => (121-29),
      )
    when "grn"
      build_pack_with_random_foil(set_code, :foil, :grn_common, {grn_common: 10, uncommon: 3, rare_or_mythic: 1, grn_land: 1})
    when "rna"
      build_pack_with_random_foil(set_code, :foil, :rna_common, {rna_common: 10, uncommon: 3, rare_or_mythic: 1, rna_land: 1})
    # These are just approximations, they actually used nonstandard sheets
    when "lea", "leb", "2ed", "3ed", "ice"
      build_pack(set_code, {common_or_basic: 11, uncommon: 3, rare: 1})
    # Early sets had unusual rarities, indexer fills all the details for us
    when "all"
      build_pack(set_code, {explicit_common: 8, explicit_uncommon: 3, explicit_rare: 1})
    when "chr"
      build_pack(set_code, {explicit_common: 9, explicit_uncommon: 3})
    when "atq", "arn", "drk", "fem", "hml"
      build_pack(set_code, {explicit_common: 6, explicit_uncommon: 2})
    when "leg"
      build_pack(set_code, {explicit_common: 12, explicit_uncommon: 3, explicit_rare: 1})
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end
  end
end

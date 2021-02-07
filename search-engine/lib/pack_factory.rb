class PackFactory
  attr_reader :sheet_cache

  def initialize(db)
    @db = db
    @sheet_factory = CardSheetFactory.new(@db)
    @sheet_cache = {}
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

  private def build_pack_with_random_foil(set_code, rate, foil_sheet, replacement_sheet, distribution, common_if_no_basic: false)
    # Previously based on https://www.reddit.com/r/magicTCG/comments/snzvt/simple_avr_sealed_simulator_i_just_made/c4fk0sr/
    #
    # We have sort of official numbers from WotC now, so use them
    # No guarantee they apply to every set ever
    foil_distribution = distribution.dup
    raise "Foil requested, but not sure which slot to replace" if foil_distribution[foil_sheet]
    raise "Foil requested, but not sure which slot to replace" unless foil_distribution[replacement_sheet]
    foil_distribution[replacement_sheet] -= 1
    foil_distribution[foil_sheet] = 1
    normal_rate = rate.denominator - rate.numerator
    foil_rate = rate.numerator

    normal_pack = build_pack(set_code, distribution, common_if_no_basic: common_if_no_basic)
    foil_pack = build_pack(set_code, foil_distribution, common_if_no_basic: common_if_no_basic)
    return WeightedPack.new({normal_pack => normal_rate, foil_pack => foil_rate})
  end

  private def build_sheet(set_code, name)
    @sheet_cache[[set_code, name]] ||= begin
      if @sheet_factory.respond_to?(name)
        # .arity and keyword arguments are weird together
        arity = @sheet_factory.method(name).arity
        if arity == 0 or arity == -1
          @sheet_factory.send(name)
        else
          @sheet_factory.send(name, set_code)
        end
      else
        raise "Unknown sheet type #{name}"
      end
    end
  end

  private def build_pack_with_independent_foils(set_code, rate, *sheets)
    den = rate.denominator
    num = rate.numerator
    cases = [[{}, 1]]
    sheets.each do |count, normal_sheet, foil_sheet|
      cases = cases.flat_map{|c, w|
        raise if c[normal_sheet]
        raise if c[foil_sheet]
        cr = count * num
        raise if cr > den
        [
          [c.merge(normal_sheet => count), w * (den - cr)],
          [c.merge(normal_sheet => count-1, foil_sheet => 1), w * cr],
        ]
      }
    end
    gcd = cases.map(&:last).inject(&:gcd)
    WeightedPack.new(
      cases.map{|variant_contents, variant_weight|
        variant_contents = variant_contents.select{|k,v| v != 0}
        [build_pack(set_code, variant_contents), variant_weight / gcd]
      }.to_h
    )
  end

  def for(set_code, variant=nil)
    variant = nil if variant == "default"
    set = @db.resolve_edition(set_code)
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize
    booster_code = [set_code, variant].compact.join("-")

    # https://mtg.gamepedia.com/Booster_pack
    pack = case booster_code
    when "ptk"
      build_pack(set_code, {basic: 2, common: 5, uncommon: 2, rare: 1})
    when "s99", "por", "p02"
      build_pack(set_code, {basic: 2, common: 9, uncommon: 3, rare: 1})
    when "ugl"
      build_pack(set_code, {basic: 1, common_unbalanced: 6, uncommon: 2, rare: 1})
    when "lea", "leb", "2ed", "3ed"
      build_pack(set_code, {explicit_common: 11, explicit_uncommon: 3, explicit_rare: 1})
    # 6ed came out after foils started, but didn't have foils
    when "4ed", "5ed", "6ed"
      build_pack(set_code, {common: 11, uncommon: 3, rare: 1})
    when "mir", "vis", "wth", "tmp", "sth", "exo", "usg"
      build_pack(set_code, {common: 11, uncommon: 3, rare: 1})
    # Old system switched from 1:100 to 1:70 in Torment, this creates a lot of combinations
    # Pre-mythic, old foil system, sets with basics
    when "mmq", "inv", "ody"
      build_pack_with_independent_foils(
        set_code,
        1/100r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common, :foil_common_or_basic],
      )
    when "ons", "mrd", "chk"
      build_pack_with_independent_foils(
        set_code,
        1/70r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common, :foil_common_or_basic],
      )
    # Pre-mythic, old foil system, sets with basics, don't try to color balance them
    when "rav"
      build_pack_with_independent_foils(
        set_code,
        1/70r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common_unbalanced, :foil_common_or_basic],
      )
    # Pre-mythic, old foil system, sets without basics
    when "ulg", "uds", "nem", "pcy", "pls" # apc below
      build_pack_with_independent_foils(
        set_code,
        1/100r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common, :foil_common],
      )
    when "tor", "lgn", "scg", "dst", "5dn", "bok", "sok" # jud below
      build_pack_with_independent_foils(
        set_code,
        1/70r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common, :foil_common],
      )
    # Pre-mythic, old foil system, sets without basics, don't try to color balance them
    # (APC should probably be balanced, just by c: not ci:)
    when "apc"
      build_pack_with_independent_foils(
        set_code,
        1/100r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common_unbalanced, :foil_common],
      )
    when "jud", "gpt", "dis"
      build_pack_with_independent_foils(
        set_code,
        1/70r,
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [11, :common_unbalanced, :foil_common],
      )
    # I couldn't find information about foils in core sets, so I'm somewhat guessing here
    # Treating all of these as independent, totals look hilariously high
    when "7ed"
      build_pack_with_independent_foils(
        set_code,
        1/100r,
        [1, :basic, :foil_basic],
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [10, :common, :foil_common],
      )
    when "8ed", "9ed", "10e"
      build_pack_with_independent_foils(
        set_code,
        1/70r,
        [1, :basic, :foil_basic],
        [1, :rare, :foil_rare],
        [3, :uncommon, :foil_uncommon],
        [10, :common, :foil_common],
      )
    # Pre-mythic, with new style foils, only foil basics in packs
    when "lrw"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {common: 11, uncommon: 3, rare: 1})
    # Pre-mythic, with new style foils, sets without basics
    when "fut", # Amazingly Future Sight has regular boring sheets
         "mor"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {common: 11, uncommon: 3, rare: 1})
    # According to pack opening videos, Coldsnap has common_or_basic slot
    when "csp"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common_or_basic, {common_or_basic: 11, uncommon: 3, rare: 1})
    # Don't try to color balance them
    when "eve", "shm"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common_unbalanced, {common_unbalanced: 11, uncommon: 3, rare: 1})
    # Default configuration since mythics got introduced
    # A lot of sets don't fit this
    when "m10", "m11", "m12", "m13", "m14", "m15",
      "con",
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
      "mh1"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {basic: 1, common: 10, uncommon: 3, rare_mythic: 1}, common_if_no_basic: true)
    when "bfz", "ogw",
      "kld", "aer"
      build_pack_with_random_foil(set_code, 9/40r, :foil_or_masterpiece_1_in_144, :common, {basic: 1, common: 10, uncommon: 3, rare_mythic: 1}, common_if_no_basic: true)
    when "akh", "hou"
      build_pack_with_random_foil(set_code, 9/40r, :foil_or_masterpiece_1_in_129, :common, {basic: 1, common: 10, uncommon: 3, rare_mythic: 1}, common_if_no_basic: true)
    when "eld", # ELD and newer sets have multiple nonstandard pack types too
      "thb"
      build_pack_with_random_foil(set_code, 1/3r, :foil, :common, {basic: 1, common: 10, uncommon: 3, rare_mythic: 1}, common_if_no_basic: true)
    when "m19"
      # According to The Collation Project, if pack has DFC (at least nonfoil), it will have checklist card in land slot
      # We do not simulate this
      build_pack_with_random_foil(set_code, 9/40r, :foil, :nonland_common, {basic_or_common_land: 1, nonland_common: 10, uncommon: 3, rare_mythic: 1})
    when "m20"
      build_pack_with_random_foil(set_code, 1/3r, :foil, :nonland_common, {basic_or_common_land: 1, nonland_common: 10, uncommon: 3, rare_mythic: 1})
    when "iko"
      # This works almost like M19/M20, but one of the common lands seems to be on common not on land sheet
      # gainlands x6, basics x4
      build_pack_with_random_foil(set_code, 1/3r, :foil, :nongainland_common, {iko_basic_or_gainland: 1, nongainland_common: 10, uncommon: 3, rare_mythic: 1})
    when "m21"
      # gainlands x6, basics x3
      build_pack_with_random_foil(set_code, 1/3r, :foil, :nongainland_common, {m21_basic_or_gainland: 1, nongainland_common: 10, uncommon: 3, rare_mythic: 1})
    when "ala"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common_unbalanced, {basic: 1, common_unbalanced: 10, uncommon: 3, rare_mythic: 1})
    when "arb"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :common_unbalanced, {common_unbalanced: 11, uncommon: 3, rare_mythic: 1})
    when "mma", "mm2", "mm3", "ema", "ima", "a25", "uma"
      build_pack(set_code, {common: 10, uncommon: 3, rare_mythic: 1, dedicated_foil: 1})
    when "2xm"
      build_pack(set_code, {common: 8, uncommon: 3, rare_mythic: 2, dedicated_foil_2xm: 2})
    when "znr"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 1/3r, :foil, :common, {basic: 1, common: 10, sfc_uncommon: 3, modaldfc_rare_mythic: 1}) => 27,
        build_pack_with_random_foil(set_code, 1/3r, :foil, :common, {basic: 1, common: 10, modaldfc_uncommon: 1, sfc_uncommon: 2, sfc_rare_mythic: 1}) => 121,
      )
    when "dgm"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :dgm_common, {dgm_common: 10, uncommon: 3, dgm_rare_mythic: 1, dgm_land: 1})
    when "frf"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :frf_common, {frf_common: 10, uncommon: 3, rare_mythic: 1, frf_land: 1})
    when "unh"
      build_pack_with_random_foil(set_code, 9/40r, :unhinged_foil, :common, {common: 10, uncommon: 3, rare_mythic: 1, basic: 1})
    when "jou"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {common: 11, uncommon: 3, rare_mythic: 1}) => 4319,
        build_pack(set_code, {theros_gods: 15}) => 1,
      )
    when "isd"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :sfc_common, {isd_dfc: 1, basic: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_mythic: 1})
    when "dka"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :sfc_common, {dka_dfc: 1, sfc_common: 10, sfc_uncommon: 3, sfc_rare_mythic: 1})
    when "tsp"
      # 10 commons, 3 uncommons, 1 rare, and 1 purple-rarity timeshifted card.
      # Basics don't fit anywhere
      build_pack_with_random_foil(set_code, 9/40r, :ts_foil, :common, {common: 10, uncommon: 3, rare: 1, tsts: 1})
    when "plc"
      # 8 commons, 2 uncommons, 1 rare, 3 timeshifted commons, and 1 uncommon or rare timeshifted card.
      build_pack_with_random_foil(set_code, 9/40r, :foil, :pc_common, {pc_common: 8, pc_uncommon: 2, pc_rare: 1, pc_cs_common: 3, pc_cs_uncommon_rare: 1})
    when "vma"
      WeightedPack.new(
        build_pack(set_code, {common: 10, uncommon: 3, rare_mythic: 1, vma_special: 1}) => 9,
        build_pack(set_code, {common: 10, uncommon: 3, rare_mythic: 1, vma_foil: 1}) => 471,
      )
      # CardSheet.new([power_9, vma_foil], [9, 471])
    when "soi"
      # Assume foil rate (1:4) and rare/mythic dfc rates (1:8) are independent
      # They probably aren't
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 9/40r, :foil, :sfc_common, {basic: 1, sfc_common: 9, sfc_uncommon: 3, sfc_rare_mythic: 1, soi_dfc_common_uncommon: 1}) => 7,
        build_pack_with_random_foil(set_code, 9/40r, :foil, :sfc_common, {basic: 1, sfc_common: 8, sfc_uncommon: 3, sfc_rare_mythic: 1, soi_dfc_common_uncommon: 1, soi_dfc_rare_mythic: 1}) => 1,
      )
    when "emn"
      # Same assumptions as SOI, except no basics in the set
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 9/40r, :foil, :sfc_common, {sfc_common: 10, sfc_uncommon: 3, sfc_rare_mythic: 1, emn_dfc_common_uncommon: 1}) => 7,
        build_pack_with_random_foil(set_code, 9/40r, :foil, :sfc_common, {sfc_common: 9, sfc_uncommon: 3, sfc_rare_mythic: 1, emn_dfc_common_uncommon: 1, emn_dfc_rare_mythic: 1}) => 1,
      )
    when "cns"
      # 1:67 cards were foil back then, so assume this is true for conspiracies, all while keeping 9/40 rate same for rest-of-the-pack (even though there's 1 less cards to in rest-of-the-pack)?
      # This cannot possibly be correct, but it's unclear which way it is incorrect
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 9/40r, :cns_nondraft_foil, :cns_nondraft_common, {cns_draft: 1, cns_nondraft_common: 10, cns_nondraft_uncommon: 3, cns_nondraft_rare_mythic: 1}) => 66,
        build_pack_with_random_foil(set_code, 9/40r, :cns_nondraft_foil, :cns_nondraft_common, {cns_draft_foil: 1, cns_nondraft_common: 10, cns_nondraft_uncommon: 3, cns_nondraft_rare_mythic: 1}) => 1,
      )
    when "cn2"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 9/40r, :cn2_nonconspiracy_foil, :cn2_nonconspiracy_common, {cn2_conspiracy: 1, cn2_nonconspiracy_common: 10, cn2_nonconspiracy_uncommon: 3, cn2_nonconspiracy_rare_mythic: 1}) => 66,
        build_pack_with_random_foil(set_code, 9/40r, :cn2_nonconspiracy_foil, :cn2_nonconspiracy_common, {cn2_conspiracy_foil: 1, cn2_nonconspiracy_common: 10, cn2_nonconspiracy_uncommon: 3, cn2_nonconspiracy_rare_mythic: 1}) => 1,
      )
    when "ust"
      # Box opening videos suggest that foil basic goes into basic slot
      # Foil contraptions would do too?
      # Ratios are total guesses
      WeightedPack.new(
        build_pack(set_code, {ust_basic: 1, ust_contraption: 2, ust_common: 8, ust_uncommon: 3, ust_rare_mythic: 1}) => 27,
        build_pack(set_code, {ust_basic: 1, ust_contraption: 2, ust_foil: 1, ust_common: 7, ust_uncommon: 3, ust_rare_mythic: 1}) => 10,
        build_pack(set_code, {ust_basic_foil: 1, ust_contraption: 2, ust_common: 8, ust_uncommon: 3, ust_rare_mythic: 1}) => 1,
        build_pack(set_code, {ust_basic: 1, ust_contraption: 1, ust_contraption_foil: 1, ust_common: 8, ust_uncommon: 3, ust_rare_mythic: 1}) => 2,
      )
    when "bbd"
      # I ran the math, and best numbers are totally weird, so some rounded:
      # 1/4 have normal foil (very close to usual packs)
      # 1/10 have partner rare/mythic (exact)
      # 2/10 have partner uncommon (off by 12%)
      # 1/100 has partner foil (who knows really)
      #
      # Those numbers are truly awful

      WeightedPack.new(
        # No partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 3, bbd_rare_mythic: 1})             => (7 * 15 - 20) * 11 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 3, bbd_rare_mythic: 1}) => (7 * 5) * 11 * 31,
        # Uncommon partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 1, bbd_uncommon_partner_1: 2, bbd_rare_mythic: 1})             => 6 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 1, bbd_uncommon_partner_1: 2, bbd_rare_mythic: 1}) => 2 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 1, bbd_uncommon_partner_2: 2, bbd_rare_mythic: 1})             => 6 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 1, bbd_uncommon_partner_2: 2, bbd_rare_mythic: 1}) => 2 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 1, bbd_uncommon_partner_3: 2, bbd_rare_mythic: 1})             => 6 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 1, bbd_uncommon_partner_3: 2, bbd_rare_mythic: 1}) => 2 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 1, bbd_uncommon_partner_4: 2, bbd_rare_mythic: 1})             => 6 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 1, bbd_uncommon_partner_4: 2, bbd_rare_mythic: 1}) => 2 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 1, bbd_uncommon_partner_5: 2, bbd_rare_mythic: 1})             => 6 * 11 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 1, bbd_uncommon_partner_5: 2, bbd_rare_mythic: 1}) => 2 * 11 * 31,
        # Rare partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_rare_partner_1: 2})             => 1 * 15 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_rare_partner_1: 2}) => 1 *  5 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_rare_partner_2: 2})             => 1 * 15 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_rare_partner_2: 2}) => 1 *  5 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_rare_partner_3: 2})             => 1 * 15 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_rare_partner_3: 2}) => 1 *  5 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_rare_partner_4: 2})             => 1 * 15 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_rare_partner_4: 2}) => 1 *  5 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_rare_partner_5: 2})             => 1 * 15 * 2 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_rare_partner_5: 2}) => 1 *  5 * 2 * 31,
        # Mythic partner
        build_pack(set_code, {basic: 1, common: 10, bbd_uncommon: 2, bbd_mythic_partner_1: 2})             => 1 * 15 * 1 * 31,
        build_pack(set_code, {basic: 1, common: 9, bbd_foil: 1, bbd_uncommon: 2, bbd_mythic_partner_1: 2}) => 1 * 5 * 1 * 31,
        # Foil partner
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_mythic_partner_1: 2, bbd_rare_mythic: 1}) => 1 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_rare_partner_1: 2, bbd_rare_mythic: 1}) => 2 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_rare_partner_2: 2, bbd_rare_mythic: 1}) => 2 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_rare_partner_3: 2, bbd_rare_mythic: 1}) => 2 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_rare_partner_4: 2, bbd_rare_mythic: 1}) => 2 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_rare_partner_5: 2, bbd_rare_mythic: 1}) => 2 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_uncommon_partner_1: 2, bbd_rare_mythic: 1}) => 4 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_uncommon_partner_2: 2, bbd_rare_mythic: 1}) => 4 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_uncommon_partner_3: 2, bbd_rare_mythic: 1}) => 4 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_uncommon_partner_4: 2, bbd_rare_mythic: 1}) => 4 * 22,
        build_pack(set_code, {basic: 1, common: 9, bbd_uncommon: 2, bbd_foil_uncommon_partner_5: 2, bbd_rare_mythic: 1}) => 4 * 22,
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
        build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {basic: 1, common: 10, dom_nonlegendary_uncommon: 3, dom_legendary_rare_mythic: 1}) => 36*(144-23),
        build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {basic: 1, common: 10, dom_nonlegendary_uncommon: 2, dom_legendary_uncommon: 1, dom_legendary_rare_mythic: 1}) => 36*23,
        build_pack_with_random_foil(set_code, 9/40r, :foil, :common, {basic: 1, common: 10, dom_nonlegendary_uncommon: 2, dom_legendary_uncommon: 1, dom_nonlegendary_rare_mythic: 1}) => (121-36)*144,
      )
    # To fully balance it like DOM, probabilities of double walker pack are negative!
    # If we disallow double planeswalker packs (rare pw and uncommon pw in same pack),
    # probabilities turn into almost perfect but not quite so values 1/1936 and 1/5808 deviation
    #
    # We can make this deviation go on rares on uncommons, either way it's too tiny to notice
    when "war"
      WeightedPack.new(
        build_pack_with_random_foil(set_code, 9/40r, :war_foil, :common, {basic: 1, common: 10, war_nonplaneswalker_uncommon: 3, war_planeswalker_rare_mythic: 1}) => 29,
        build_pack_with_random_foil(set_code, 9/40r, :war_foil, :common, {basic: 1, common: 10, war_nonplaneswalker_uncommon: 2, war_planeswalker_uncommon: 1, war_nonplaneswalker_rare_mythic: 1}) => (121-29),
      )
    when "grn"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :grn_common, {grn_common: 10, uncommon: 3, rare_mythic: 1, grn_land: 1})
    when "rna"
      build_pack_with_random_foil(set_code, 9/40r, :foil, :rna_common, {rna_common: 10, uncommon: 3, rare_mythic: 1, rna_land: 1})
    when "ice"
      build_pack(set_code, {common: 11, uncommon: 3, rare: 1})
    # Early sets had unusual rarities, indexer fills all the details for us
    when "all"
      build_pack(set_code, {explicit_common: 8, explicit_uncommon: 3, explicit_rare: 1})
    when "chr"
      build_pack(set_code, {explicit_common: 9, explicit_uncommon: 3})
    when "atq", "arn", "drk", "fem", "hml"
      build_pack(set_code, {explicit_common: 6, explicit_uncommon: 2})
    when "leg"
      build_pack(set_code, {explicit_common: 12, explicit_uncommon: 3, explicit_rare: 1})
    when "mb1"
      build_pack(set_code, {
        mb1_white_a: 1,
        mb1_white_b: 1,
        mb1_blue_a: 1,
        mb1_blue_b: 1,
        mb1_black_a: 1,
        mb1_black_b: 1,
        mb1_red_a: 1,
        mb1_red_b: 1,
        mb1_green_a: 1,
        mb1_green_b: 1,
        mb1_multicolor: 1,
        mb1_colorless: 1,
        mb1_old_frame: 1,
        mb1_rare: 1,
        mb1_foil: 1,
      })
    when "cmb1"
      build_pack(set_code, {
        mb1_white_a: 1,
        mb1_white_b: 1,
        mb1_blue_a: 1,
        mb1_blue_b: 1,
        mb1_black_a: 1,
        mb1_black_b: 1,
        mb1_red_a: 1,
        mb1_red_b: 1,
        mb1_green_a: 1,
        mb1_green_b: 1,
        mb1_multicolor: 1,
        mb1_colorless: 1,
        mb1_old_frame: 1,
        mb1_rare: 1,
        mb1_playtest: 1,
      })
    when "ala-premium"
      build_pack(set_code, {
        alara_premium_basic: 1,
        alara_premium_common: 10,
        alara_premium_uncommon: 3,
        alara_premium_rare_mythic: 1,
      })
    when "klr-arena", "akr-arena",
      "znr-arena", "eld-arena", "thb-arena", "rix-arena", "xln-arena"
      # Arena-only boosters, 14 card booster (no basic at all)
      build_pack(set_code, {common: 10, uncommon: 3, rare_mythic: 1})
    when "m19-arena"
      # Arena-only boosters, 15 card booster (basic or common land in last slot)
      # every set does it slightly differently so listed separately
      build_pack(set_code, {basic_or_common_land: 1, nonland_common: 10, uncommon: 3, rare_mythic: 1})
    when "m20-arena"
      build_pack(set_code, {basic_or_common_land: 1, nonland_common: 10, uncommon: 3, rare_mythic: 1})
    when "iko-arena"
      build_pack(set_code, {iko_basic_or_gainland: 1, nongainland_common: 10, uncommon: 3, rare_mythic: 1})
    when "m21-arena"
      build_pack(set_code, {m21_basic_or_gainland: 1, nongainland_common: 10, uncommon: 3, rare_mythic: 1})
    when "war-arena"
      # 14 card, special
      WeightedPack.new(
        build_pack(set_code, {common: 10, war_nonplaneswalker_uncommon: 3, war_planeswalker_rare_mythic: 1}) => 29,
        build_pack(set_code, {common: 10, war_nonplaneswalker_uncommon: 2, war_planeswalker_uncommon: 1, war_nonplaneswalker_rare_mythic: 1}) => (121-29),
      )
    when "grn-arena"
      build_pack(set_code, {grn_common: 10, uncommon: 3, rare_mythic: 1, grn_land: 1})
    when "rna-arena"
      build_pack(set_code, {rna_common: 10, uncommon: 3, rare_mythic: 1, rna_land: 1})
    when "dom-arena"
      # Same notes as with regular boosters, this math isn't completely trustworthy
      WeightedPack.new(
        build_pack(set_code, {common: 10, dom_nonlegendary_uncommon: 3, dom_legendary_rare_mythic: 1}) => 36*(144-23),
        build_pack(set_code, {common: 10, dom_nonlegendary_uncommon: 2, dom_legendary_uncommon: 1, dom_legendary_rare_mythic: 1}) => 36*23,
        build_pack(set_code, {common: 10, dom_nonlegendary_uncommon: 2, dom_legendary_uncommon: 1, dom_nonlegendary_rare_mythic: 1}) => (121-36)*144,
      )
    when "khm"
      build_pack_with_random_foil(set_code, 1/3r, :foil, :non_basictype_common, {khm_basictype: 1, non_basictype_common: 10, uncommon: 3, rare_mythic: 1})
    when "khm-arena"
      build_pack(set_code, {khm_basictype: 1, non_basictype_common: 10, uncommon: 3, rare_mythic: 1})
    when "cmr"
      # Unofficial, based on some opening videos
      build_pack(set_code, {
        common: 13,
        cmr_nonlegendary_uncommon: 3,
        cmr_nonlegendary_rare_mythic: 1,
        cmr_legendary: 2,
        cmr_dedicated_foil: 1,
      })
    else
      # No packs for this set, let caller figure it out
      # Specs make sure right specs hit this
      nil
    end

    if pack
      pack.set = set
      pack.code = booster_code
      if variant
        pack.name = set.booster_variants[variant]
      else
        pack.name = set.name
      end
    end
    pack
  end
end

class CardSheetFactory
  def initialize(db)
    @db = db
  end

  def inspect
    "#{self.class}"
  end

  def mix_sheets(*sheets)
    sheets = sheets.select{|s,w| s}
    return nil if sheets.size == 0
    return sheets[0][0] if sheets.size == 1
    CardSheet.new(sheets.map(&:first), sheets.map{|s,w| s.elements.size * w})
  end

  def from_query(query, assert_count=nil, foil: false, kind: CardSheet, baseset: false)
    cards = find_cards(query, assert_count, foil: foil, baseset: baseset)
    kind.new(cards)
  end

  def find_cards(query, assert_count=nil, foil: false, baseset: false)
    base_query = "++ is:booster"
    if foil
      base_query += " is:foil"
    else
      base_query += " is:nonfoil"
    end
    if baseset
      base_query += " number<=set"
    end
    cards = @db.search("#{base_query} (#{query})").printings.map{|c| PhysicalCard.for(c, foil)}.uniq
    if assert_count and assert_count != cards.size
      raise "Expected query #{query} to return #{assert_count}, got #{cards.size}"
    end
    cards
  end

  def rarity(set_code, rarity, foil: false, baseset: false, kind: CardSheet)
    set = @db.sets[set_code]
    cards = set.physical_cards(foil).select(&:in_boosters?)
    # raise "#{set.code} #{set.same} has no cards in boosters" if cards.empty?
    cards = cards.select{|c| c.rarity == rarity}
    # This is really helpful for modelling showcase cards
    # and we only implemented them for IKO
    if baseset
      cards = cards.select{|c| c.number.to_i <= c.set.base_set_size }
    end
    # raise "#{set.code} #{set.same} has no #{rarity} cards in boosters" if cards.empty?
    return nil if cards.empty?
    kind.new(cards)
  end

  ### Usual Sheet Types

  # We don't have anywhere near reliable information
  #
  # These numbers could be totally wrong. I base them on a million guesses by various internet commenters.
  #
  # Maro says basic foils and common foils are equally likely [https://twitter.com/maro254/status/938830320094216192]
  def foil(set_code)
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      common_or_basic(set_code, foil: true),
    ]
    weights = [3, 5, 12]
    CardSheet.new(sheets, weights)
  end

  def emn_foil
    sheets = [
      rare_mythic("emn", foil: true),
      rarity("emn", "uncommon", foil: true),
      foil_common_or_borrowed_basic("emn", "soi"),
    ]
    weights = [3, 5, 12]
    CardSheet.new(sheets, weights)
  end

  # Masterpieces supposedly are in 1/144 booster (then 1/129 for Amonkhet), and they're presumably equally likely
  # 1:129 rate is not too hard to get, 1:144 is hard
  def foil_or_masterpiece_1_in_144(set_code)
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      common_or_basic(set_code, foil: true),
      masterpieces_for(set_code),
    ]
    weights = [3*8, 5*8, 12*8-2, 5]
    CardSheet.new(sheets, weights)
  end

  def ogw_foil_or_masterpiece_1_in_144
    sheets = [
      rare_mythic("ogw", foil: true),
      rarity("ogw", "uncommon", foil: true),
      foil_common_or_borrowed_basic("ogw", "bfz"),
      masterpieces_for("ogw"),
    ]
    weights = [3*8, 5*8, 12*8-2, 5]
    CardSheet.new(sheets, weights)
  end

  def aer_foil_or_masterpiece_1_in_144
    sheets = [
      rare_mythic("aer", foil: true),
      rarity("aer", "uncommon", foil: true),
      foil_common_or_borrowed_basic("aer", "kld"),
      masterpieces_for("aer"),
    ]
    weights = [3*8, 5*8, 12*8-2, 5]
    CardSheet.new(sheets, weights)
  end

  def foil_or_masterpiece_1_in_129(set_code)
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      common_or_basic(set_code, foil: true),
      masterpieces_for(set_code),
    ]
    weights = [3*7, 5*7, 12*7, 5]
    CardSheet.new(sheets, weights)
  end

  # According to tehtmi from Collation Project
  # foil rate in regular sets is close to 12 / 5 / 3
  # but sets with dedicated slots have much worse 10 / 3 / 1 rate
  #
  # This rate guarantees same foil:nonfoil rate for every rarity
  def dedicated_foil(set_code)
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      common_or_basic(set_code, foil: true),
    ]
    weights = [1, 3, 10]
    CardSheet.new(sheets, weights)
  end

  # name backwards as name starts with a number
  def dedicated_foil_double_masters(set_code)
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      common_or_basic(set_code, foil: true),
    ]
    weights = [2, 3, 8]
    CardSheet.new(sheets, weights)
  end

  def cmr_dedicated_foil
    set_code = "cmr"
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      from_query("e:#{set_code} (r:common or r:special)", 141 + 1, foil: true)
    ]
    weights = [1, 3, 13]
    CardSheet.new(sheets, weights)
  end

  def clb_dedicated_foil
    set_code = "clb"
    sheets = [
      rare_mythic(set_code, foil: true),
      rarity(set_code, "uncommon", foil: true),
      from_query("e:#{set_code} (r:common or r:special)", 140 + 1, foil: true)
    ]
    weights = [1, 3, 13]
    CardSheet.new(sheets, weights)
  end

  def common_or_basic(set_code, foil: false, kind: ColorBalancedCardSheet)
    set = @db.sets[set_code]
    cards = set.physical_cards(foil).select(&:in_boosters?)
    cards = cards.select{|c| c.rarity == "basic" or c.rarity == "common"}
    return nil if cards.empty?
    kind.new(cards)
  end

  def foil_common_or_borrowed_basic(set_code, borrow_set_code)
    from_query("(r:common e:#{set_code}) or (r:basic e:#{borrow_set_code})", foil: true)
  end

  def special(set_code)
    rarity(set_code, "special")
  end

  def common(set_code)
    rarity(set_code, "common", kind: ColorBalancedCardSheet)
  end

  def common_unbalanced(set_code)
    rarity(set_code, "common")
  end

  def basic(set_code)
    rarity(set_code, "basic")
  end

  def uncommon(set_code)
    rarity(set_code, "uncommon")
  end

  def uncommon_baseset(set_code)
    rarity(set_code, "uncommon", baseset: true)
  end

  def rare(set_code)
    rarity(set_code, "rare")
  end

  # If rare or mythic sheet contains subsheets
  # treat variants as 1/N chance eachs
  # This only matters for Unstable
  # Rares appear 2x more frequently on shared sheet
  def rare_mythic(set_code, foil: false)
    mix_sheets(
      [rarity(set_code, "rare", foil: foil), 2],
      [rarity(set_code, "mythic", foil: foil), 1]
    )
  end

  def rare_mythic_baseset(set_code, foil: false)
    mix_sheets(
      [rarity(set_code, "rare", foil: foil, baseset: true), 2],
      [rarity(set_code, "mythic", foil: foil, baseset: true), 1]
    )
  end

  private def masterpiece_sheet(set, range)
    CardSheet.new(set
      .printings
      .select{|c| range === c.number.to_i }
      .map{|c| PhysicalCard.for(c, true) })
  end

  def masterpieces_for(set_code)
    case set_code
    when "bfz"
      masterpiece_sheet(@db.sets["exp"], 1..25)
    when "ogw"
      masterpiece_sheet(@db.sets["exp"], 26..45)
    when "kld"
      masterpiece_sheet(@db.sets["mps"], 1..30)
    when "aer"
      masterpiece_sheet(@db.sets["mps"], 31..54)
    when "akh"
      masterpiece_sheet(@db.sets["mp2"], 1..30)
    when "hou"
      masterpiece_sheet(@db.sets["mp2"], 31..54)
    else
      nil
    end
  end

  ### Based on explicit data from indexer
  def explicit_land(set_code, foil: false)
    explicit_sheet(set_code, "L", foil: foil)
  end

  def explicit_common(set_code, foil: false)
    explicit_sheet(set_code, "C", foil: foil)
  end

  def explicit_uncommon(set_code, foil: false)
    explicit_sheet(set_code, "U", foil: foil)
  end

  def explicit_rare(set_code, foil: false)
    explicit_sheet(set_code, "R", foil: foil)
  end

  def mb1_white_a
    explicit_sheet_1("mb1", "WA")
  end

  def mb1_white_b
    explicit_sheet_1("mb1", "WB")
  end

  def mb1_blue_a
    explicit_sheet_1("mb1", "UA")
  end

  def mb1_blue_b
    explicit_sheet_1("mb1", "UB")
  end

  def mb1_black_a
    explicit_sheet_1("mb1", "BA")
  end

  def mb1_black_b
    explicit_sheet_1("mb1", "BB")
  end

  def mb1_red_a
    explicit_sheet_1("mb1", "RA")
  end

  def mb1_red_b
    explicit_sheet_1("mb1", "RB")
  end

  def mb1_green_a
    explicit_sheet_1("mb1", "GA")
  end

  def mb1_green_b
    explicit_sheet_1("mb1", "GB")
  end

  def mb1_multicolor
    explicit_sheet_1("mb1", "MC")
  end

  def mb1_colorless
    explicit_sheet_1("mb1", "CL")
  end

  def mb1_old_frame
    explicit_sheet_1("mb1", "OF")
  end

  def mb1_rare
    explicit_sheet_1("mb1", "R")
  end

  def mb1_foil
    from_query("e:fmb1", foil: true)
  end

  def mb1_playtest
    from_query("e:cmb1")
  end

  def mb1_playtest2
    from_query("e:cmb2")
  end

  def explicit_sheet(set_code, print_sheet_code, foil: false)
    cards = @db.sets[set_code].printings.select{|c| c.in_boosters? and c.print_sheet&.include?(print_sheet_code) }
    groups = cards.group_by{|c| c.print_sheet[/#{print_sheet_code}(\d+)/, 1].to_i }
    subsheets = groups.map{|mult,cards| [CardSheet.new(cards.map{|c| PhysicalCard.for(c, foil) }), mult] }
    mix_sheets(*subsheets)
  end

  def explicit_sheet_1(set_code, print_sheet_code)
    cards = @db.sets[set_code].printings.select{|c| c.in_boosters? and c.print_sheet == print_sheet_code}
    physical_cards = cards.map{|c| PhysicalCard.for(c) }.uniq
    CardSheet.new(physical_cards)
  end

  ### These are really unique sheets

  def dgm_land
    mix_sheets(
      [from_query("is:shockland e:rtr,gtc", 10), 1], # 10 / 242
      [from_query("e:dgm t:gate", 10), 23],          # 230 / 242
      [from_query("e:dgm maze end", 1), 2],          # 2 / 242
    )
  end

  def dgm_common
    from_query("e:dgm r:common -t:gate", 60, kind: ColorBalancedCardSheet)
  end

  def dgm_rare_mythic
    mix_sheets(
      [from_query("e:dgm r:rare", 35), 2],
      [from_query("e:dgm r:mythic -(maze end)", 10), 1]
    )
  end

  def unhinged_foil_rares
    # Super Secret Tech is 141/140
    from_query("e:unh r>=rare", 40+1, foil: true)
  end

  def unhinged_foil
    sheets = [
      unhinged_foil_rares,
      rarity("unh", "uncommon", foil: true),
      common_or_basic("unh", foil: true),
    ]
    weights = [
      3,
      5,
      12,
    ]
    CardSheet.new(sheets, weights)
  end

  def frf_land
    mix_sheets(
      [from_query("e:ktk is:fetchland", 5), 2],  #  1 / 24
      [from_query("e:frf is:gainland", 10), 23], # 23 / 24
    )
  end

  def frf_common
    from_query("e:frf r:common -is:gainland", 60, kind: ColorBalancedCardSheet)
  end

  def theros_gods
    from_query("t:god b:theros", 15)
  end

  # https://www.mtgsalvation.com/forums/magic-fundamentals/magic-general/327956-innistrad-block-transforming-card-pack-odds#c4
  # ISD: 121 card sheet
  # 1 Mythic printed 1 time = 1 total. 1/121 odds.
  # 6 Rares printed 2 times = 12 total. 2/121 odds.
  # 7 Uncommons printed 6 times = 42 total. 6/121 odds.
  # 6 Commons printed 11 times = 66 total. 11/121 odds.

  # DKA: 80 card sheet
  # 2 Mythics printed 1 time = 2 total. 1/80 odds.
  # 3 Rares printed 2 times = 6 total. 2/80 odds.
  # 4 Uncommons printed 6 times = 24 total. 6/80 odds.
  # 4 Commons printed 12 times = 48 total. 12/80 odds
  def isd_dfc
    mix_sheets(
      [from_query("e:isd is:dfc r:mythic", 1), 1],
      [from_query("e:isd is:dfc r:rare", 6), 2],
      [from_query("e:isd is:dfc r:uncommon", 7), 6],
      [from_query("e:isd is:dfc r:common", 6), 11],
    )
  end

  def dka_dfc
    mix_sheets(
      [from_query("e:dka is:dfc r:mythic", 2), 1],
      [from_query("e:dka is:dfc r:rare", 3), 2],
      [from_query("e:dka is:dfc r:uncommon", 4), 6],
      [from_query("e:dka is:dfc r:common", 4), 12],
    )
  end

  def dfc_uncommon(set_code)
    from_query("e:#{set_code} r:uncommon (is:dfc or is:meld or is:modaldfc)")
  end

  def dfc_common(set_code)
    from_query("e:#{set_code} r:common (is:dfc or is:meld or is:modaldfc)")
  end

  def sfc_common(set_code)
    from_query("e:#{set_code} r:common -is:dfc -is:meld -is:modaldfc", kind: ColorBalancedCardSheet)
  end

  def sfc_uncommon(set_code)
    from_query("e:#{set_code} r:uncommon -is:dfc -is:meld -is:modaldfc")
  end

  def sfc_rare_mythic(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:rare -is:dfc -is:meld -is:modaldfc"), 2],
      [from_query("e:#{set_code} r:mythic -is:dfc -is:meld -is:modaldfc"), 1],
    )
  end

  def dfc_rare_mythic(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:rare (is:dfc or is:meld or is:modaldfc)"), 2],
      [from_query("e:#{set_code} r:mythic (is:dfc or is:meld or is:modaldfc)"), 1],
    )
  end

  def tsts
    from_query("e:tsb", 121)
  end

  # Can't find any information.
  # So just making up something: basic foils are in packs (even though basics aren't),
  # and tsts replaces 1/4 of foil commons
  def ts_foil
    sheets = [
      rarity("tsp", "rare", foil: true),
      rarity("tsp", "uncommon", foil: true),
      foil_common_or_basic("tsp"),
      from_query("e:tsb", 121, foil: true),
    ]
    weights = [
      1,
      2,
      4,
      1,
    ]
    CardSheet.new(sheets, weights)
  end

  # Basically making it up
  def tsr_foil
    sheets = [
      rare_mythic("tsr", foil: true),
      rarity("tsr", "uncommon", foil: true),
      rarity("tsr", "common", foil: true),
      rarity("tsr", "special", foil: true),
    ]
    weights = [
      1,
      2,
      4,
      1,
    ]
    CardSheet.new(sheets, weights)
  end

  def pc_common
    from_query("e:plc r:common -is:colorshifted", 40)
  end

  def pc_uncommon
    from_query("e:plc r:uncommon -is:colorshifted", 40)
  end

  def pc_rare
    from_query("e:plc r:rare -is:colorshifted", 40)
  end

  def pc_cs_common
    from_query("e:plc r:common is:colorshifted", 20)
  end

  def pc_cs_uncommon_rare
    # Wiki says:
    # "a timeshifted uncommon being three times more likely than a rare
    # due to the relative numbers of each in the set"
    # This translates to 40 card 15xU2/10xU1 style sheet
    mix_sheets(
      [from_query("e:plc r:uncommon is:colorshifted", 15), 2],
      [from_query("e:plc r:rare is:colorshifted", 10), 1],
    )
  end

  def vma_special
    from_query("e:vma r:special", 9)
  end

  def vma_foil
    # https://magic.wizards.com/en/articles/archive/arcana/vintage-masterss-special-rarity-2014-05-12-0
    vma_foil_rare = mix_sheets(
      [rarity("vma", "special", foil: true), 1],
      [rarity("vma", "mythic", foil: true), 2],
      [rarity("vma", "rare", foil: true), 4],
    )
    CardSheet.new(
      [
        vma_foil_rare,
        rarity("vma", "uncommon", foil: true),
        rarity("vma", "common", foil: true),
      ],
      [3, 5, 12],
    )
  end

  # https://www.lethe.xyz/mtg/collation/soi.html
  def soi_dfc_common_uncommon
    # 10x4xC + 4x20xU = 120 cards on sheet
    mix_sheets(
      [from_query("e:soi r:common is:dfc", 4), 5],
      [from_query("e:soi r:uncommon is:dfc", 20), 2],
    )
  end

  def soi_dfc_rare_mythic
    # This rate is so standard it's pretty much guaranteed, even if sheet size (15) is weird
    mix_sheets(
      [from_query("e:soi r:rare is:dfc", 6), 2],
      [from_query("e:soi r:mythic is:dfc", 3), 1],
    )
  end

  # https://www.lethe.xyz/mtg/collation/emn.html
  def emn_dfc_common_uncommon
    # 15x4xC + 6x10xU = 120 cards od sheet
    mix_sheets(
      [from_query("e:emn r:common is:front (is:dfc or is:meld)", 4), 5],
      [from_query("e:emn r:uncommon is:front (is:dfc or is:meld)", 10), 2],
    )
  end

  def emn_dfc_rare_mythic
    # sheet size 12?
    mix_sheets(
      [from_query("e:emn r:rare is:front (is:dfc or is:meld)", 5), 2],
      [from_query("e:emn r:mythic is:front (is:dfc or is:meld)", 2), 1],
    )
  end

  # According to maro, these are legendary creatures, not planeswalkers or other legendaries
  # For DMU it's officially confirmed https://github.com/taw/magic-sealed-data/issues/24
  def dom_legendary_uncommon
    from_query('e:dom t:"legendary creature" r:uncommon', 20)
  end

  def dom_nonlegendary_uncommon
    from_query('e:dom -t:"legendary creature" r:uncommon', 60)
  end

  def dom_legendary_rare_mythic
    mix_sheets(
      [from_query('e:dom t:"legendary creature" r:rare', 14), 2],
      [from_query('e:dom t:"legendary creature" r:mythic', 8), 1],
    )
  end

  def dom_nonlegendary_rare_mythic
    mix_sheets(
      [from_query('e:dom -t:"legendary creature" r:rare', 39), 2],
      [from_query('e:dom -t:"legendary creature" r:mythic', 7), 1],
    )
  end

  def dmu_legendary_uncommon
    from_query('e:dmu t:"legendary creature" r:uncommon', 20)
  end

  def dmu_nonlegendary_uncommon
    from_query('e:dmu -t:"legendary creature" r:uncommon', 60)
  end

  def dmu_legendary_rare_mythic
    mix_sheets(
      [from_query('e:dmu t:"legendary creature" r:rare', 14), 2],
      [from_query('e:dmu t:"legendary creature" r:mythic', 7), 1],
    )
  end

  def dmu_nonlegendary_rare_mythic
    mix_sheets(
      [from_query('e:dmu -t:"legendary creature" r:rare', 46), 2],
      [from_query('e:dmu -t:"legendary creature" r:mythic', 13), 1],
    )
  end

  def war_planeswalker_uncommon
    from_query('e:war t:planeswalker r:uncommon -number:/★/', 20)
  end

  def war_nonplaneswalker_uncommon
    from_query('e:war -t:planeswalker r:uncommon', 60)
  end

  def war_planeswalker_rare_mythic
    mix_sheets(
      [from_query('e:war t:planeswalker r:rare -number:/★/', 13), 2],
      [from_query('e:war t:planeswalker r:mythic -number:/★/', 3), 1],
    )
  end

  def war_nonplaneswalker_rare_mythic
    mix_sheets(
      [from_query('e:war -t:planeswalker r:rare', 40), 2],
      [from_query('e:war -t:planeswalker r:mythic', 12), 1],
    )
  end

  def war_foil
    m = from_query("e:war r:mythic -number:/★/", 15, foil: true)
    r = from_query("e:war r:rare -number:/★/", 53, foil: true)
    u = from_query("e:war r:uncommon -number:/★/", 80, foil: true)
    c = common_or_basic("war", foil: true)
    mr = mix_sheets([r, 2], [m, 1])
    CardSheet.new([mr, u, c], [3, 5, 12])
  end

  def cns_draft_foil
    cns_draft(true)
  end

  def cns_draft(foil=false)
    mix_sheets(
      [from_query('e:cns is:draft r:common', 9, foil: foil), 4],
      [from_query('e:cns is:draft r:uncommon', 8, foil: foil), 2],
      [from_query('e:cns is:draft r:rare', 8, foil: foil), 1],
    )
  end

  def cns_nondraft_foil
    sheets = [
      cns_nondraft_common(true),
      cns_nondraft_uncommon(true),
      cns_nondraft_rare_mythic(true),
    ]
    weights = [
      12,
      5,
      3,
    ]
    CardSheet.new(sheets, weights)
  end

  def cns_nondraft_common(foil=false)
    from_query('e:cns -is:draft r:common', 80, foil: foil, kind: ColorBalancedCardSheet)
  end

  def cns_nondraft_uncommon(foil=false)
    from_query('e:cns -is:draft r:uncommon', 60, foil: foil)
  end

  def cns_nondraft_rare_mythic(foil=false)
    mix_sheets(
      [from_query('e:cns -is:draft r:rare', 35, foil: foil), 2],
      [from_query('e:cns -is:draft r:mythic', 10, foil: foil), 1],
    )
  end

  def cn2_conspiracy_foil
    cn2_conspiracy(true)
  end

  def cn2_conspiracy(foil=false)
    mix_sheets(
      [from_query('e:cn2 t:conspiracy r:common', 5, foil: foil), 8],
      [from_query('e:cn2 t:conspiracy r:uncommon', 2, foil: foil), 4],
      [from_query('e:cn2 t:conspiracy r:rare', 3, foil: foil), 2],
      [from_query('e:cn2 t:conspiracy r:mythic', 2, foil: foil), 1],
    )
  end

  def cn2_nonconspiracy_foil
    sheets = [
      cn2_nonconspiracy_common(true),
      cn2_nonconspiracy_uncommon(true),
      cn2_nonconspiracy_rare_mythic(true),
    ]
    weights = [
      12,
      5,
      3,
    ]
    CardSheet.new(sheets, weights)
  end

  def cn2_nonconspiracy_common(foil=false)
    from_query('e:cn2 -t:conspiracy r:common', 85, foil: foil, kind: ColorBalancedCardSheet)
  end

  def cn2_nonconspiracy_uncommon(foil=false)
    from_query('e:cn2 -t:conspiracy r:uncommon', 65, foil: foil)
  end

  def cn2_nonconspiracy_rare_mythic(foil=false)
    foilcond = foil ? "-is:nonfoilonly" : "-is:foilonly"
    # foil Kaya is extra
    # nonfoil Kaya is not
    mix_sheets(
      [from_query('e:cn2 -t:conspiracy r:rare', 47, foil: foil), 2],
      [from_query("e:cn2 -t:conspiracy r:mythic #{foilcond}", 12, foil: foil), 1],
    )
  end

  def grn_common
    from_query("e:grn r:common not:guildgate", kind: ColorBalancedCardSheet)
  end

  def grn_land
    from_query("e:grn is:guildgate", 10)
  end

  def rna_common
    from_query("e:rna r:common not:guildgate", kind: ColorBalancedCardSheet)
  end

  def rna_land
    from_query("e:rna is:guildgate", 10)
  end

  def bbd_uncommon(foil=false)
    from_query("e:bbd r:uncommon -has:partner", 70, foil: foil)
  end

  def bbd_mythic_partner_1
    from_query("e:bbd r:mythic has:partner (number=1 or number=2)", 2)
  end

  def bbd_rare_partner_1
    from_query("e:bbd r:rare has:partner (number=3 or number=4)", 2)
  end

  def bbd_rare_partner_2
    from_query("e:bbd r:rare has:partner (number=5 or number=6)", 2)
  end

  def bbd_rare_partner_3
    from_query("e:bbd r:rare has:partner (number=7 or number=8)", 2)
  end

  def bbd_rare_partner_4
    from_query("e:bbd r:rare has:partner (number=9 or number=10)", 2)
  end

  def bbd_rare_partner_5
    from_query("e:bbd r:rare has:partner (number=11 or number=12)", 2)
  end

  def bbd_uncommon_partner_1
    from_query("e:bbd r:uncommon has:partner (number=13 or number=14)", 2)
  end

  def bbd_uncommon_partner_2
    from_query("e:bbd r:uncommon has:partner (number=15 or number=16)", 2)
  end

  def bbd_uncommon_partner_3
    from_query("e:bbd r:uncommon has:partner (number=17 or number=18)", 2)
  end

  def bbd_uncommon_partner_4
    from_query("e:bbd r:uncommon has:partner (number=19 or number=20)", 2)
  end

  def bbd_uncommon_partner_5
    from_query("e:bbd r:uncommon has:partner (number=21 or number=22)", 2)
  end

  def bbd_foil_mythic_partner_1
    from_query("e:bbd r:mythic has:partner (number=255 or number=256)", 2, foil: true)
  end

  def bbd_foil_rare_partner_1
    from_query("e:bbd r:rare has:partner (number=3 or number=4)", 2, foil: true)
  end

  def bbd_foil_rare_partner_2
    from_query("e:bbd r:rare has:partner (number=5 or number=6)", 2, foil: true)
  end

  def bbd_foil_rare_partner_3
    from_query("e:bbd r:rare has:partner (number=7 or number=8)", 2, foil: true)
  end

  def bbd_foil_rare_partner_4
    from_query("e:bbd r:rare has:partner (number=9 or number=10)", 2, foil: true)
  end

  def bbd_foil_rare_partner_5
    from_query("e:bbd r:rare has:partner (number=11 or number=12)", 2, foil: true)
  end

  def bbd_foil_uncommon_partner_1
    from_query("e:bbd r:uncommon has:partner (number=13 or number=14)", 2, foil: true)
  end

  def bbd_foil_uncommon_partner_2
    from_query("e:bbd r:uncommon has:partner (number=15 or number=16)", 2, foil: true)
  end

  def bbd_foil_uncommon_partner_3
    from_query("e:bbd r:uncommon has:partner (number=17 or number=18)", 2, foil: true)
  end

  def bbd_foil_uncommon_partner_4
    from_query("e:bbd r:uncommon has:partner (number=19 or number=20)", 2, foil: true)
  end

  def bbd_foil_uncommon_partner_5
    from_query("e:bbd r:uncommon has:partner (number=21 or number=22)", 2, foil: true)
  end

  def bbd_rare_mythic(foil=false)
    mix_sheets(
      [from_query('e:bbd -has:partner r:rare', 43, foil: foil), 2],
      [from_query('e:bbd -has:partner r:mythic', 13, foil: foil), 1],
    )
  end

  # These foil rates are pretty much total :poopemoji:
  def bbd_foil
    sheets = [
      from_query("e:bbd (r:common or r:basic)", 101 + 5, foil: true),
      bbd_uncommon(true),
      bbd_rare_mythic(true),
    ]
    weights = [
      12,
      5,
      3,
    ]
    CardSheet.new(sheets, weights)
  end

  def ust_basic(foil: false)
    mix_sheets(
      [from_query('e:ust r:basic', 5, foil: foil), 24],
      [from_query("e:ust border:black", 1, foil: foil), 1],
    )
  end

  def ust_basic_foil
    ust_basic(foil: true)
  end

  # Numbers are totally made up
  # Maybe some rarity is actually not exact?
  def ust_contraption(foil: false)
    mix_sheets(
      [from_query("e:ust t:contraption r:common", 15, foil: foil), 8],
      [from_query("e:ust t:contraption r:uncommon", 15, foil: foil), 4],
      [from_query("e:ust t:contraption r:rare", 10, foil: foil), 2],
      [from_query("e:ust t:contraption r:mythic", 5, foil: foil), 1],
    )
  end

  def ust_contraption_foil
    ust_contraption(foil: true)
  end

  def ust_foil
    sheets = [
      explicit_common("ust", foil: true),
      explicit_uncommon("ust", foil: true),
      explicit_rare("ust", foil: true),
    ]
    weights = [
      12,
      5,
      3,
    ]
    CardSheet.new(sheets, weights)
  end

  # The whole this is a mess, the only consistent thing is that showcases are 1/3 of each card occurences
  # rare and uncommon have same ratio as normally
  # commons/lands are just messed up
  def iko_foil
    # L = 60 = 15 x 2 + 10 x 3
    # C = 303 = 101 x 3
    # U = 240 = 80 x 3
    # R = 363 = 121 x 3
    sheets = [
      CardSheet.new([
          from_query("e:iko (r:basic or is:gainland)", 25, foil: true),
          explicit_common("iko", foil: true),
        ], [25, 101],
      ),
      explicit_uncommon("iko", foil: true),
      explicit_rare("iko", foil: true),
    ]
    weights = [
      12,
      5,
      3,
    ]
    CardSheet.new(sheets, weights)
  end

  def nonland_common(set_code)
    from_query("e:#{set_code} r:common -t:land", kind: ColorBalancedCardSheet)
  end

  def nongainland_common(set_code)
    from_query("e:#{set_code} r:common -is:gainland", kind: ColorBalancedCardSheet)
  end

  def nongainland_common_baseset(set_code)
    from_query("e:#{set_code} r:common -is:gainland", baseset: true, kind: ColorBalancedCardSheet)
  end

  def basic_or_common_land(set_code)
    from_query("e:#{set_code} t:land r<=common")
  end

  # These also have L2/L3 codes, but these aren't actually used by the code
  def iko_basic_or_gainland(foil: false)
    mix_sheets(
      [from_query("e:iko t:basic", 15, foil: foil), 2],
      [from_query("e:iko is:gainland", 10, foil: foil), 3]
    )
  end

  def m21_basic_or_gainland
    # showcase variant which is just as common as any other basic land variation
    mix_sheets(
      [from_query("e:m21 t:basic", 20), 3],
      [from_query("e:m21 is:gainland", 10), 6]
    )
  end

  def alara_premium_basic
    from_query("b:ala r:basic", 20 + 0 + 0, foil: true)
  end

  def alara_premium_common
    from_query("b:ala r:common", 101 + 60 + 60, foil: true)
  end

  def alara_premium_uncommon
    from_query("b:ala r:uncommon", 60 + 40 + 40, foil: true)
  end

  def alara_premium_rare_mythic
    mix_sheets(
      [from_query("b:ala r:rare", 53+35+35, foil: true), 2],
      [from_query("b:ala r:mythic", 15+10+10, foil: true), 1]
    )
  end

  def modaldfc_rare_mythic(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:rare is:modaldfc"), 2],
      [from_query("e:#{set_code} r:mythic is:modaldfc"), 1],
    )
  end

  def modaldfc_uncommon(set_code)
    from_query("e:#{set_code} r:uncommon is:modaldfc")
  end

  def cmr_nonlegendary_uncommon
    from_query('e:cmr -t:legendary r:uncommon', 80)
  end

  # Not sure what's the rate, 4:2:1 is likely incorrect
  def cmr_legendary
    mix_sheets(
      [from_query('e:cmr t:legendary r:uncommon', 40), 4],
      [from_query('e:cmr t:legendary r:rare', 25), 2],
      [from_query('e:cmr t:legendary r:mythic', 5), 1],
    )
  end

  # 2*52 + 17 = 121
  def cmr_nonlegendary_rare_mythic
    mix_sheets(
      [from_query('e:cmr -t:legendary r:rare', 52), 2],
      [from_query('e:cmr -t:legendary r:mythic', 17), 1],
    )
  end

  def clb_nonlegendary_common
    from_query('e:clb -t:legendary r:common', 136)
  end

  def clb_nonlegendary_uncommon
    from_query('e:clb -t:legendary r:uncommon', 75)
  end

  def clb_nonlegendary_rare_mythic
    mix_sheets(
      [from_query('e:clb -t:"legendary creature" -t:"legendary planeswalker" -t:background r:rare', 47), 2], # legendary land in this slot???
      [from_query('e:clb -t:legendary r:mythic', 17), 1],
    )
  end

  # no idea about ratios
  def clb_legendary
    mix_sheets(
      [from_query('e:clb t:legendary -t:background -t:land r:uncommon', 30), 4],
      [from_query('e:clb t:legendary -t:background -t:land r:rare', 25), 2],
      [from_query('e:clb t:legendary -t:background -t:land r:mythic', 5), 1],
    )
  end

  # no idea about ratios
  def clb_background
    mix_sheets(
      [from_query('e:clb t:background r:common', 5), 4],
      [from_query('e:clb t:background r:uncommon', 15), 2],
      [from_query('e:clb t:background r:rare', 5), 1],
    )
  end

  def foil_common(set_code)
    rarity(set_code, "common", foil: true)
  end

  def foil_basic(set_code)
    rarity(set_code, "basic", foil: true)
  end

  def foil_common_or_basic(set_code)
    common_or_basic(set_code, foil: true, kind: CardSheet)
  end

  def foil_uncommon(set_code)
    rarity(set_code, "uncommon", foil: true)
  end

  def foil_rare(set_code)
    rarity(set_code, "rare", foil: true)
  end

  def khm_basictype(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:common (t:island or t:mountain or t:swamp or t:forest or t:plains)", 10), 5],
      [from_query("e:#{set_code} r:basic", 10), 7],
    )
  end

  def non_basictype_common(set_code)
    from_query("e:#{set_code} r:common -t:island -t:mountain -t:swamp -t:forest -t:plains", kind: ColorBalancedCardSheet)
  end

  def sta
    # Each Draft Booster also has a dedicated slot with an uncommon (67%), rare (26.4%), or mythic rare (6.6%) Mystical Archive card.
    # https://magic.wizards.com/en/articles/archive/feature/collecting-strixhaven-school-mages-2021-03-25
    mix_sheets(
      [from_query("e:sta r:mythic", 15), 3],
      [from_query("e:sta r:rare", 30), 6],
      [from_query("e:sta r:uncommon", 18), 25],
    )
  end

  def stx_lesson
    # ratio is guessed, and most likely wrong
    # uncommons are on uncommon sheet!
    mix_sheets(
      [from_query("e:stx t:lesson r:mythic", 1), 1],
      [from_query("e:stx t:lesson r:rare", 5), 2],
      [from_query("e:stx t:lesson r:common", 9), 11],
    )
  end

  def nonlesson_common(set_code)
    from_query("e:#{set_code} r:common -t:lesson", kind: ColorBalancedCardSheet)
  end

  def nonlesson_rare_mythic(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:rare -t:lesson"), 2],
      [from_query("e:#{set_code} r:mythic -t:lesson"), 1],
    )
  end

  def mh2_new_to_modern
    mix_sheets(
      [from_query('e:mh2 number>=262 r:uncommon', 20), 5],
      [from_query('e:mh2 number>=262 r:rare', 18), 2],
      [from_query('e:mh2 number>=262 r:mythic', 4), 1],
    )
  end

  def mh2_normal_uncommon
    from_query('e:mh2 number<262 r:uncommon', 80)
  end

  def mh2_normal_rare_mythic
    mix_sheets(
      [from_query('e:mh2 number<262 r:rare', 60), 2],
      [from_query('e:mh2 number<262 r:mythic', 20), 1],
    )
  end

  def dbl_mid_sfc_common
    from_query("e:dbl r:common is:sfc number<=267", 90)
  end

  def dbl_mid_dfc_common
    from_query("e:dbl r:common is:dfc number<=267", 10)
  end

  def dbl_mid_sfc_uncommon
    from_query("e:dbl r:uncommon is:sfc number<=267", 60)
  end

  def dbl_mid_dfc_uncommon
    from_query("e:dbl r:uncommon is:dfc number<=267", 23)
  end

  def dbl_mid_sfc_rare_mythic
    mix_sheets(
      [from_query("e:dbl r:rare is:sfc number<=267", 53), 2],
      [from_query("e:dbl r:mythic is:sfc number<=267", 15), 1],
    )
  end

  def dbl_mid_dfc_rare_mythic
    mix_sheets(
      [from_query("e:dbl r:rare is:dfc number<=267", 11), 2],
      [from_query("e:dbl r:mythic is:dfc number<=267", 5), 1],
    )
  end

  def dbl_vow_sfc_common
    from_query("e:dbl r:common is:sfc number>267", 90)
  end

  def dbl_vow_dfc_common
    from_query("e:dbl r:common is:dfc number>267", 10)
  end

  def dbl_vow_sfc_uncommon
    from_query("e:dbl r:uncommon is:sfc number>267", 60)
  end

  def dbl_vow_dfc_uncommon
    from_query("e:dbl r:uncommon is:dfc number>267", 23)
  end

  def dbl_vow_sfc_rare_mythic
    mix_sheets(
      [from_query("e:dbl r:rare is:sfc number>267", 53), 2],
      [from_query("e:dbl r:mythic is:sfc number>267", 15), 1],
    )
  end

  def dbl_vow_dfc_rare_mythic
    mix_sheets(
      [from_query("e:dbl r:rare is:dfc number>267", 11), 2],
      [from_query("e:dbl r:mythic is:dfc number>267", 5), 1],
    )
  end

  def neo_dfc_common_uncommon
    # Guessing the rate. With this rate:
    # SFC uncommon rarity 3/80
    # DFC uncommon rarity 3/10 * (1/10) = 3/80
    # but SFC commons are vastly overrepresented
    sheets = [
      from_query("e:neo r:common is:dfc", 6),
      from_query("e:neo r:uncommon is:dfc", 8),
    ]
    CardSheet.new(sheets, [7, 3])
  end

  def neo_sfc_common
    from_query("e:neo r:common -is:gainland -is:dfc", kind: ColorBalancedCardSheet)
  end

  def neo_land
    from_query("e:neo (r:basic or is:gainland)", 30)
  end

  def snc_basic
    mix_sheets(
      [from_query("e:snc r:basic number<272", 10), 2],
      [from_query("e:snc r:basic number>=272", 10), 1],
    )
  end

  def sunf_sticker
    from_query("e:sunf t:stickers", 48)
  end

  def brr_retro_artifact
    # Officially 1/6 schematc rate
    # U/R/M rates guessed to be at 4x/2x/1x multiples
    mix_sheets(
      [from_query("e:brr ++ number<=63 r:uncommon", 18), 4*5],
      [from_query("e:brr ++ number<=63 r:rare", 30), 2*5],
      [from_query("e:brr ++ number<=63 r:mythic", 15), 1*5],
      [from_query("e:brr ++ number>=64 r:uncommon", 18), 4],
      [from_query("e:brr ++ number>=64 r:rare", 30), 2],
      [from_query("e:brr ++ number>=64 r:mythic", 15), 1],
    )
  end

  # Just treat BRO+BRR as one set for foiling purposes
  # This is likely to be inaccurate, but we never get accurate foil rate information anyway
  def bro_foil
    sheets = [
      mix_sheets(
        [from_query("e:bro,brr r:rare", foil: true), 2],
        [from_query("e:bro,brr r:mythic", foil: true), 1],
      ),
      from_query("e:bro,brr r:uncommon", foil: true),
      from_query("e:bro,brr r<=common", foil: true),
    ]
    weights = [3, 5, 12]
    CardSheet.new(sheets, weights)
  end

  # Mech basic officially 1/4 rate
  # Regular nonfoil basics are not in the packs
  def bro_mech_basic
    from_query("e:bro r:basic number>=278", 10)
  end

  # 30a is not valid identifier
  def a30_common
    from_query("e:30a r:common number<=297", 74)
  end

  def a30_uncommon
    from_query("e:30a r:uncommon number<=297", 95)
  end

  # Each dual land has 2x the normal frequency. This is true for both modern frame and retro frame dual lands.
  def a30_rare
    mix_sheets(
      [from_query("e:30a r:rare is:dual number<=297", 10), 2],
      [from_query("e:30a r:rare -is:dual number<=297", 103), 1],
    )
  end

  def a30_basic
    from_query("e:30a r:basic number<=297", 15)
  end

  def a30_retro_basic
    from_query("e:30a r:basic number>297", 15)
  end

  # We know two things:
  # - "approximately three out of every ten packs will contain a rare retro frame card"
  # - "Each dual land has 2x the normal frequency. This is true for both modern frame and retro frame dual lands."
  # This is not how normal cards (6% rare) or foils (15% rare) work
  #
  # But that's not quite saying they're all equally likely (except duals double), as then we'd have 40% rare.
  # Flat-ish but not totally flat distribution where C/Dual is 2x, U is 1.5x, R is 1x fits the distribution
  # with rare ratio on 29.7% and very clean numbers.
  # Yes this means retro dual is as frequent as retro common, which sounds weird
  def a30_retro
    mix_sheets(
      [from_query("e:30a r:common number>297", 74), 4],
      [from_query("e:30a r:uncommon number>297", 95), 3],
      [from_query("e:30a r:rare is:dual number>297", 10), 4],
      [from_query("e:30a r:rare -is:dual number>297", 103), 2],
    )
  end

  def one_praetor
    from_query("(e:neo number:59) or (e:dmu number:107) or (e:snc number:129) or (e:khm number:199)", 4)
  end
end

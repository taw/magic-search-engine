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

  def from_query(query, assert_count=nil, foil: false, kind: CardSheet)
    cards = find_cards(query, assert_count, foil: foil)
    kind.new(cards)
  end

  def find_cards(query, assert_count=nil, foil: false)
    if foil
      base_query = "++ is:booster is:foil"
    else
      base_query = "++ is:booster is:nonfoil"
    end
    cards = @db.search("#{base_query} (#{query})").printings.map{|c| PhysicalCard.for(c, foil)}.uniq
    if assert_count and assert_count != cards.size
      raise "Expected query #{query} to return #{assert_count}, got #{cards.size}"
    end
    cards
  end

  ### Usual Sheet Types

  # We don't have anywhere near reliable information
  # Masterpieces supposedly are in 1/144 booster (then 1/129 for Amonkhet), and they're presumably equally likely
  #
  # These numbers could be totally wrong. I base them on a million guesses by various internet commenters.
  #
  # Maro says basic foils and common foils are equally likely [https://twitter.com/maro254/status/938830320094216192]
  def foil(set_code)
    sheets = [rare_mythic(set_code, foil: true), rarity(set_code, "uncommon", foil: true)]
    weights = [4, 8]

    masterpieces = masterpieces_for(set_code)
    if masterpieces
      sheets << masterpieces
      weights << 1
    end

    sheets << common_or_basic(set_code, foil: true)
    weights << (32 - weights.sum)

    CardSheet.new(sheets, weights)
  end

  def rarity(set_code, rarity, foil: false, kind: CardSheet)
    set = @db.sets[set_code]
    cards = set.physical_cards(foil).select(&:in_boosters?)
    # raise "#{set.code} #{set.same} has no cards in boosters" if cards.empty?
    cards = cards.select{|c| c.rarity == rarity}
    # raise "#{set.code} #{set.same} has no #{rarity} cards in boosters" if cards.empty?
    return nil if cards.empty?
    kind.new(cards)
  end

  def common_or_basic(set_code, foil: false, kind: ColorBalancedCardSheet)
    set = @db.sets[set_code]
    cards = set.physical_cards(foil).select(&:in_boosters?)
    cards = cards.select{|c| c.rarity == "basic" or c.rarity == "common"}
    return nil if cards.empty?
    kind.new(cards)
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

  def explicit_common(set_code)
    explicit_sheet(set_code, "C")
  end

  def explicit_uncommon(set_code)
    explicit_sheet(set_code, "U")
  end

  def explicit_rare(set_code)
    explicit_sheet(set_code, "R")
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

  def explicit_sheet(set_code, print_sheet_code)
    cards = @db.sets[set_code].printings.select{|c| c.in_boosters? and c.print_sheet.include?(print_sheet_code) }
    groups = cards.group_by{|c| c.print_sheet[/#{print_sheet_code}(\d+)/, 1].to_i }
    subsheets = groups.map{|mult,cards| [CardSheet.new(cards.map{|c| PhysicalCard.for(c) }), mult] }
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
    from_query("e:unh r>=rare", 40+1, foil: true)
  end

  def unhinged_foil
    sheets = [
      unhinged_foil_rares,
      rarity("unh", "uncommon", foil: true),
      rarity("unh", "basic", foil: true),
      rarity("unh", "common", foil: true),
    ]
    weights = [
      1,
      2,
      1,
      4,
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

  def sfc_common(set_code)
    from_query("e:#{set_code} r:common -is:dfc -is:meld", kind: ColorBalancedCardSheet)
  end

  def sfc_uncommon(set_code)
    from_query("e:#{set_code} r:uncommon -is:dfc -is:meld")
  end

  def sfc_rare_mythic(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:rare -is:dfc -is:meld"), 2],
      [from_query("e:#{set_code} r:mythic -is:dfc -is:meld"), 1],
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
      rarity("tsp", "basic", foil: true),
      rarity("tsp", "common", foil: true),
      from_query("e:tsb", 121, foil: true),
    ]
    weights = [
      1,
      2,
      1,
      3,
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
    # https://magic.wizards.com/en/articles/archive/arcana/vintage-masterss-special-rarity-2014-05-12-0
    power_9 = from_query("e:vma r:special", 9)
    vma_foil_rare = mix_sheets(
      [rarity("vma", "special", foil: true), 1],
      [rarity("vma", "mythic", foil: true), 2],
      [rarity("vma", "rare", foil: true), 4],
    )
    vma_foil = CardSheet.new(
      [
        vma_foil_rare,
        rarity("vma", "uncommon", foil: true),
        rarity("vma", "common", foil: true),
      ],
      [1, 2, 5],
    )
    CardSheet.new([power_9, vma_foil], [9, 471])
  end

  def soi_dfc_common_uncommon
    # sheet size 32?
    mix_sheets(
      [from_query("e:soi r:common is:dfc", 4), 3],
      [from_query("e:soi r:uncommon is:dfc", 20), 1],
    )
  end

  def soi_dfc_rare_mythic
    # This rate is so standard it's pretty much guaranteed, even if sheet size (15) is weird
    mix_sheets(
      [from_query("e:soi r:rare is:dfc", 6), 2],
      [from_query("e:soi r:mythic is:dfc", 3), 1],
    )
  end

  def emn_dfc_common_uncommon
    # sheet size 22?
    mix_sheets(
      [from_query("e:emn r:common is:front (is:dfc or is:meld)", 4), 3],
      [from_query("e:emn r:uncommon is:front (is:dfc or is:meld)", 10), 1],
    )
  end

  def emn_dfc_rare_mythic
    # sheet size 12?
    mix_sheets(
      [from_query("e:emn r:rare is:front (is:dfc or is:meld)", 5), 2],
      [from_query("e:emn r:mythic is:front (is:dfc or is:meld)", 2), 1],
    )
  end

  # These are legendary creatures only according to maro
  # not planeswalkers or other legendaries
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
    CardSheet.new([mr, u, c], [4, 8, 20])
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
      5,
      2,
      1,
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
      5,
      2,
      1,
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

  def bbd_uncommon_partner(foil=false)
    from_query("e:bbd r:uncommon has:partner", 10, foil: foil, kind: PartnerCardSheet)
  end

  def bbd_rare_mythic(foil=false)
    mix_sheets(
      [from_query('e:bbd -has:partner r:rare', 43, foil: foil), 2],
      [from_query('e:bbd -has:partner r:mythic', 13, foil: foil), 1],
    )
  end

  def bbd_rare_mythic_partner
    sheets = [
      from_query("e:bbd r:rare has:partner", 10, kind: PartnerCardSheet),
      from_query("e:bbd r:mythic has:partner is:nonfoilonly", 2, kind: PartnerCardSheet),
    ]
    weights = [
      10,
      1,
    ]
    MixedPartnerCardSheet.new(sheets, weights)
  end

  # These foil rates are pretty much total :poopemoji:
  def bbd_foil
    sheets = [
      from_query("e:bbd (r:common or r:basic)", 101 + 5, foil: true),
      bbd_uncommon(true),
      bbd_rare_mythic(true),
    ]
    weights = [
      5,
      2,
      1,
    ]
    CardSheet.new(sheets, weights)
  end

  def bbd_foil_partner
    sheets = [
      from_query("e:bbd r:uncommon has:partner", 10, foil: true, kind: PartnerCardSheet),
      from_query("e:bbd r:rare has:partner", 10, foil: true, kind: PartnerCardSheet),
      from_query("e:bbd r:mythic has:partner is:foilonly", 2, foil: true, kind: PartnerCardSheet),
    ]
    weights = [
      20,
      10,
      1,
    ]
    MixedPartnerCardSheet.new(sheets, weights)
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

  def ust_common(foil: false)
    from_query("e:ust r:common -t:contraption", 82, foil: foil)
  end

  def ust_uncommon(foil: false)
    from_query("e:ust r:uncommon -t:contraption", 75, foil: foil)
  end

  def ust_rare_mythic(foil: false)
    mix_sheets(
      [from_query('e:ust -t:contraption -border:black r:rare', 50, foil: foil), 2],
      [from_query('e:ust -t:contraption r:mythic', 10, foil: foil), 1],
    )
  end

  # Numbers are totally made up
  # Maybe some rarity is actually not exact?
  def ust_contraption(foil: false)
    mix_sheets(
      [from_query('e:ust t:contraption r:common', 15, foil: foil), 8],
      [from_query('e:ust t:contraption r:uncommon', 15, foil: foil), 4],
      [from_query('e:ust t:contraption r:rare', 10, foil: foil), 2],
      [from_query('e:ust t:contraption r:mythic', 5, foil: foil), 1],
    )
  end

  def ust_contraption_foil
    ust_contraption(foil: true)
  end

  def ust_foil
    sheets = [
      ust_common(foil: true),
      ust_uncommon(foil: true),
      ust_rare_mythic(foil: true),
    ]
    weights = [
      5,
      2,
      1,
    ]
    CardSheet.new(sheets, weights)
  end

  def nonland_common(set_code)
    from_query("e:#{set_code} r:common -t:land", kind: ColorBalancedCardSheet)
  end

  def nongainland_common(set_code)
    from_query("e:#{set_code} r:common -is:gainland", kind: ColorBalancedCardSheet)
  end

  def basic_or_common_land(set_code)
    from_query("e:#{set_code} t:land r<=common")
  end

  def basic_or_gainland(set_code)
    from_query("e:#{set_code} (t:basic or is:gainland)")
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
end

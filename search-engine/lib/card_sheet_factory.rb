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

  def from_query(query, assert_count=nil, foil: false)
    cards = @db.search("++ #{query}").printings.map{|c| PhysicalCard.for(c, foil)}.uniq
    if assert_count and assert_count != cards.size
      raise "Expected query #{query} to return #{assert_count}, got #{cards.size}"
    end
    CardSheet.new(cards)
  end

  ### Usual Sheet Types

  # Wo don't have anywhere near reliable information
  # Masterpieces supposedly are in 1/144 booster (then 1/129 for Amonkhet), and they're presumably equally likely
  #
  # These numbers could be totally wrong. I base them on a million guesses by various internet commenters.
  def foil_sheet(set_code)
    sheets = [rare_or_mythic(set_code, foil: true), rarity(set_code, "uncommon", foil: true)]
    weights = [4, 8]

    masterpieces = masterpieces_for(set_code)
    if masterpieces
      sheets << masterpieces
      weights << 1
    end

    basic_sheet = rarity(set_code, "basic", foil: true)
    if basic_sheet
      sheets << basic_sheet
      weights << 4
    end

    sheets << rarity(set_code, "common", foil: true)
    weights << (32 - weights.inject(0, &:+))

    CardSheet.new(sheets, weights)
  end

  def rarity(set_code, rarity, foil: false)
    set = @db.sets[set_code]
    cards = set.physical_cards(foil).select(&:in_boosters?)
    # raise "#{set.code} #{set.same} has no cards in boosters" if cards.empty?
    cards = cards.select{|c| c.rarity == rarity}
    # raise "#{set.code} #{set.same} has no #{rarity} cards in boosters" if cards.empty?
    if cards.empty?
      nil
    else
      CardSheet.new(cards)
    end
  end

  # If rare or mythic sheet contains subsheets
  # treat variants as 1/N chance eachs
  # This only matters for Unstable
  # Rares appear 2x more frequently on shared sheet
  def rare_or_mythic(set_code, foil: false)
    mix_sheets(
      [rarity(set_code, "rare", foil: foil), 2],
      [rarity(set_code, "mythic", foil: foil), 1]
    )
  end

  def common_or_basic(set_code)
    # Assume basics are just commons for sheet purposes
    mix_sheets(
      [rarity(set_code, "common"), 1],
      [rarity(set_code, "basic"), 1],
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
      masterpiece_sheet(@db.sets["mps_akh"], 1..30)
    when "hou"
      masterpiece_sheet(@db.sets["mps_akh"], 31..54)
    else
      nil
    end
  end

  ### Very old mixed rarity sheets

  # Antiquities U3 (uncommon) / U1 (rare) approximation
  def u3u1(set_code)
    mix_sheets(
      [rarity(set_code, "uncommon"), 3],
      [rarity(set_code, "rare"), 1],
    )
  end

  # Arabian Nights U3 (uncommon) / U2 (rare) approximation
  def u3u2(set_code)
    mix_sheets(
      [rarity(set_code, "uncommon"), 3],
      [rarity(set_code, "rare"), 2],
    )
  end

  # The Dark U2 (uncommon) / U1 (rare) approximation
  def u2u1(set_code)
    mix_sheets(
      [rarity(set_code, "uncommon"), 2],
      [rarity(set_code, "rare"), 1],
    )
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
    from_query("e:dgm r:common -t:gate", 60)
  end

  def dgm_rare_mythic
    mix_sheets(
      [from_query("e:dgm r:rare", 35), 2],
      [from_query("e:dgm r:mythic -(maze end)", 10), 1]
    )
  end

  def unhinged_foil_rares
    from_query("e:uh r>=rare", 40+1, foil: true)
  end

  def unhinged_foil
    sheets = [
      unhinged_foil_rares,
      rarity("uh", "uncommon", foil: true),
      rarity("uh", "basic", foil: true),
      rarity("uh", "common", foil: true),
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
    from_query("e:frf r:common -is:gainland", 60)
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
    from_query("e:#{set_code} r:common -is:dfc")
  end

  def sfc_uncommon(set_code)
    from_query("e:#{set_code} r:uncommon -is:dfc")
  end

  def sfc_rare_or_mythic(set_code)
    mix_sheets(
      [from_query("e:#{set_code} r:rare -is:dfc"), 2],
      [from_query("e:#{set_code} r:mythic -is:dfc"), 1],
    )
  end

  def tsts
    from_query("e:tsts", 121)
  end

  # Can't find any information.
  # So just making up something: basic foils are in packs (even though basics aren't),
  # and tsts replaces 1/4 of foil commons
  def ts_foil
    sheets = [
      rarity("ts", "rare", foil: true),
      rarity("ts", "uncommon", foil: true),
      rarity("ts", "basic", foil: true),
      rarity("ts", "common", foil: true),
      from_query("e:tsts", 121, foil: true),
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
    from_query("e:pc r:common -is:colorshifted", 40)
  end

  def pc_uncommon
    from_query("e:pc r:uncommon -is:colorshifted", 40)
  end

  def pc_rare
    from_query("e:pc r:rare -is:colorshifted", 40)
  end

  def pc_cs_common
    from_query("e:pc r:common is:colorshifted", 20)
  end

  def pc_cs_uncommon_rare
    # Wiki says:
    # "a timeshifted uncommon being three times more likely than a rare
    # due to the relative numbers of each in the set"
    # This translates to 40 card 15xU2/10xU1 style sheet
    mix_sheets(
      [from_query("e:pc r:uncommon is:colorshifted", 15), 2],
      [from_query("e:pc r:rare is:colorshifted", 10), 1],
    )
  end
end

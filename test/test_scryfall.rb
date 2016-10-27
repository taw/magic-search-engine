# Examples from https://scryfall.com/docs/syntax
# and how they work on mtg.wtf

require_relative "test_helper"

class ScryfallTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_crg_and_or
    # we follow MCI style AND
    assert_search_equal "c:rg", "c:r OR c:g"
    # scryfall follows AND
    assert_search_differ "c:rg", "c:r AND c:g"
    # It's arguable which behaviour is better
  end

  # FIXME: scryfall supports "c:red" too
  def test_color_alias
    # color: is alias for c:
    assert_search_equal "color:uw -c:r", "(c:u OR c:w) -c:r"
    # it's still OR, not AND
    assert_search_differ "color:uw -c:r", "(c:u AND c:w) -c:r"
  end

  def test_colorless
    # results differ due to uncards, but functionality is overall the same
    assert_search_include "c:c t:creature",
      "Abundant Maw",
      "Accomplished Automaton",
      "Barrage Tyrant",
      "Bastion Mastodon"
  end

  def test_multicolor
    # results are the same (except for scryfall including spoiler cards)
    assert_search_include "c:m t:instant",
      "Abrupt Decay",
      "Aethertow",
      "Bound",
      "Determined"
    # This is arguable case as both sides are monocolored,
    # but full cards is sort of multicolored (fuse or no fuse)
    assert_search_exclude "c:m t:instant",
      "Turn", "Burn",
      "Fire", "Ice"
  end

  def test_reserved
    # identical behaviour, at least until they abolish the damn list
    assert_count_results "is:reserved", 571
  end

  def test_meld
    # identical behaviour, count both parts and melded cards
    assert_count_results "is:meld", 9
  end

  def test_ft_designed
    # identical results
    assert_count_results 'ft:"designed" e:m15', 15
  end

  def test_ft_mishra
    # results differ due to uncards
    assert_search_include 'ft:"mishra"',
      "Battering Ram",
      "Ankh of Mishra",
      "Mishra's Toy Workshop"
  end

  def test_creature_type
    # scryfall includes changelings as every creature type
    assert_search_include "t:merfolk t:legendary",
      "Jori En, Ruin Diver"
    assert_search_exclude "t:merfolk t:legendary",
      "Mistform Ultimus"
    # same here
    assert_search_include "t:legendary (t:goblin or t:elf)",
      "Edric, Spymaster of Trest",
      "Ib Halfheart, Goblin Tactician"
    assert_search_exclude "t:legendary (t:goblin or t:elf)",
      "Mistform Ultimus"
    # same here
    assert_search_include "t:fish or t:bird",
      "Ancient Carp",
      "Augury Owl"
    assert_search_exclude "t:fish or t:bird",
      "Taurean Mauler"
  end

  def test_tribal_type
    # scryfall includes changelings as every creature type
    assert_search_include "t:goblin -t:creature",
      "Tarfire"
    assert_search_exclude "t:goblin -t:creature",
      "Ego Erasure"
  end

  def test_banned_commander
    # scryfall does the silly thing of counting conspiracies
    # as "banned" instead of as non-cards
    assert_search_include "banned:commander",
      "Black Lotus"
    assert_search_exclude "banned:commander",
      "Backup Plan"
  end

  def test_restricted_vintage
    # Identical results
    assert_count_results "restricted:vintage", 43
  end

  def test_e_mm2
    # Identical results
    assert_count_results "e:mm2", 249
  end

  def test_b_zen
    # Identical results
    assert_count_results "b:zen", 607
  end

  def test_b_wwk
    # scryfall allows any set code to be block code
    # maybe that's a good idea
    assert_count_results "b:wwk", 0
  end

  def test_frame_future
    assert_search_equal "frame:future", "is:future"
  end

  def test_m_gg
    # m: as extra alias for mana: is fine,
    # but what scryfall does with m: being symbol-level m>= is insanity

    assert_search_equal "m={g}{g}", "mana={g}{g}"
    assert_search_equal "m:{g}{g}", "mana:{g}{g}"
    assert_search_equal "m:{g}{g}", "m={g}{g}"

    # scryfall thinks 2gg should match gg
    assert_search_include "m:{g}{g}", "Bassara Tower Archer"
    assert_search_exclude "m:{g}{g}", "Abundance"

    # scryfall thinks m:4 should match 4g but not 5, that's just nonsense
    assert_search_include "m:4", "Solemn Simulacrum"
    assert_search_exclude "m:4", "Ballista Charger", "Air Servant"

    assert_search_include "m>=4",
      "Solemn Simulacrum",  # 4
      "Abhorrent Overlord", # 5bb
      "Aether Searcher",    # 7
      "Aethersnatch"        # 4uu
    assert_search_exclude "m>=4",
      "Academy Elite"       # 3u
  end

  def test_m_2ww
    # same problems as m:{g}{g}
    assert_search_equal "m:2WW", "cmc=4 c:w m:2ww"
  end

  def test_m_up
    # same problems
    assert_search_results "m:{U/P}",
      "Gitaxian Probe",
      "Mental Misstep"
  end

  def test_is_split
    # Results differ due to uncards
    assert_search_include "is:split",
      "Alive", "Well",
      "Boom", "Bust",
      "Naughty", "Nice"
  end

  def test_exact_fire
    assert_search_results "!Fire", "Fire"
  end

  def test_exact_sift_through_sands
    assert_search_results '!sift through sands', "Sift Through Sands"
    assert_search_results '!"sift through sands"', "Sift Through Sands"
  end


  def test_is_commander
    # arguable if banned cards should be included,
    # but there are multiple commander-like formats
    # with multiple banlists
    assert_search_include "is:commander",
      "Erayo, Soratami Ascendant",
      "Daretti, Scrap Savant",
      "Agrus Kos, Wojek Veteran",
      "Griselbrand",
      "Bruna, the Fading Light",
      "Ulrich of the Krallenhorde"

    # Ton of scryfall bugs with cards which are
    # legendary creatures on non-prmary sides
    assert_search_exclude "is:commander",
      "Erayo's Essence",
      "Autumn-Tail, Kitsune Sage",
      "Brisela, Voice of Nightmares",
      "Hanweir, the Writhing Township",
      "Ormendahl, Profane Prince",
      "Ulrich, Uncontested Alpha",
      "Withengar Unbound",
      "Elbrus, the Binding Blade"
  end

  def test_parentheses
    # Identical results
    assert_search_results "through (depths or sands or mists)",
      "Peer Through Depths",
      "Reach Through Mists",
      "Sift Through Sands"
  end

  def test_gideon_in_any_field
    # identical results
    assert_search_include "ft:gideon or o:gideon or t:gideon or gideon",
      "Call the Gatewatch", # ft:
      "Gideon, Battle-Forged", # t: / name:
      "Gideon's Lawkeeper"  # name
    assert_search_exclude "ft:gideon or o:gideon or t:gideon or gideon",
      "Kytheon, Hero of Akros"
  end

  def test_pow_gt_8
    # results differ in uncards / spoiled cards
    assert_search_include "pow>=8",
      "Akron Legionnaire",
      "Aradara Express",
      "Archdemon of Greed",
      "Brisela, Voice of Nightmares",
      "Crash of Rhinos",
      "Uktabi Kong"
  end

  def test_loyalty
    assert_search_equal "t:planeswalker loy=3", "t:planeswalker loyalty=3"
    assert_search_include "t:planeswalker loy=3",
      "Saheeli Rai",
      "Arlinn Kord",
      "Liliana, Defiant Necromancer"
  end

  def test_artist
    # scryfall does t:*
    # it's arguable which way is better
    assert_search_include 'a:"proce"',
      "Undercity Plague"
    assert_search_exclude 'a:"proce"',
      "Tazeem"
  end

  def test_tazeem
    # scryfall does t:*, including planes by default
    assert_search_results "tazeem",
      "Guardian of Tazeem"
  end

  def test_is_colorshifted
    # MCI is:timeshifted is SF is:colorshifted
    # SF is:timeshifted is e:tsts
    # no good way out so we just alias is:colorshifted to is:timeshifted
    assert_search_equal "is:colorshifted", "is:timeshifted"
    assert_count_results "is:timeshifted", 45
  end

  def test_oracle_tilde
    # identical results, except for spoilers
    assert_search_include 'o:"~ enters the battlefield tapped"',
      "Deadlock Trap",
      "Port Town",
      "Izzet Boilerworks"
  end

  def test_white_creature_standard
    # identical results
    assert_search_include 'c:w t:creature f:standard',
      "Aerial Responder",
      "Wispweaver Angel"
  end

  def test_pow_gt_tou
    # identical results except uncards and spoilers
    assert_search_include "pow>tou c:w t:creature",
      "Abzan Battle Priest"
      "Blade of the Sixth Pride"
  end

  def test_border
    assert_search_equal "border:white t:creature", "is:white-bordered t:creature"
  end

  def test_color_identity
    # id: as alias for ci:
    # works the same except for uncards
    assert_search_equal "id:c t:land", "ci:c t:land"

    # scryfall id is >=, which is completely pointless
    #   except when looking for commander for existing cards
    # mtg.wtf ci:/id: is <=, which is for what you want
    #   for looking for cards for existing commander deck
    assert_search_include "id:rug is:permanent",
      "Accomplished Automaton",        # 1
      "Kozilek, the Great Distortion", # c
      "Aether Meltdown",               # u
      "Izzet Boilerworks",             # ru
      "Avalanche Tusker"               # rug
    # Any color not in id: should block it
    assert_search_exclude "id:rug is:permanent",
      "Prism Array",          # wubrg
      "Glint-Eye Nephilim",   # ubrg
      "Abomination of Gudul", # bgu
      "Akroan Hoplite",       # wr
      "Abbey Griffin"         # w
  end

  def test_identity_but_not_color
    # this is correct behaviour:
    assert_search_include "-c:u id:u",
      "Abstruse Interference", # devoid card with u color identity
      "Adaptive Automaton",    # colorless card with colorless color identity
      "Silver Myr",            # colorless card with u color identity
      "Academy Ruins"          # land with u color identity

    # this is scryfall being silly:
    assert_search_exclude "-c:u id:u",
      "Azorius Chancery",      # land with uw color identity
      "Agent of Horizons",     # g card with gu color identity
      "Turn", "Burn"           # split card with ur color identity

  end

  def test_br_spell_standard
    # MCI/mtg.wtf c: works as OR
    # scryfall c: works as AND

    assert_search_equal "c:br is:spell f:standard", "(c:b or c:r) is:spell f:standard"
  end

  def test_ignore_plusplus
    # ++ is display control directive, and right now they live on frontend side,
    # not on search engine side (except sort:, which lives in between)
    # It shouldn't affect the results
    # (but maybe we shuld pass it as flag to frontend?)

    assert_search_equal '++!"Lightning Bolt"', '!"Lightning Bolt"'
    assert_search_equal '++t:forest a:"john avon"', 't:forest a:"john avon"'
    assert_search_equal '++yamazaki', 'yamazaki'
    # There's a small problem here that we use MCI code AI for Alliances,
    # so "all" triggers subset search, matching "Alliances" and "Fallen Empires"
    assert_search_equal '++e:all', 'e:all'
  end

  def test_new_frame
    # scryfall distinguishes "modern" and "new" frame
    # mtg.wtf and MCI treat them as same frame
    # maybe scryfall has a point here?

    # no old/future frame mythics
    assert_search_equal "is:new r:mythic", "r:mythic"
  end

  def test_scryfall_bug_cmc
    # meld cmc is sum of part cmcs
    assert_search_exclude "c:c t:creature cmc=0", "Chittering Host"
    # flip cmc equals other part, weirdly it only affect some cards, not all
    assert_search_exclude "ravager cmc=0", "Ravager of the Fells"
  end

  def test_scryfall_bug_uncards
    # scryfall doesn't include uncards at all
    assert_search_include "clay", "Clay Pigeon"
  end

  def test_red_creatures_with_cmc_2_or_less
    # scryfall currently failing due to cmc bugs
    assert_search_exclude "c:r t:creature cmc<=2",
      "Ravager of the Fells"
  end

  def test_blue_cmc_5
    # scryfall cmc errors again
    assert_search_include "c:u cmc=5",
      "Ghastly Haunting",
      "Soul Seizer"
  end

  def test_common_artifact
    # differ due to uncards
    assert_search_include "r:common t:artifact",
      "Abzan Banner",
      "Accorder's Shield", # was both common and uncommon
      "Paper Tiger" # uncard
  end

  def test_oracle_ignores_reminder_text
    # scryfall repeating MCI's mistakes and not cleaning up reminder text
    assert_search_include 'o:"draw" t:creature',
      "Abomination of Gudul"
    assert_search_exclude 'o:"draw" t:creature',
      "Tireless Tracker"
  end
end

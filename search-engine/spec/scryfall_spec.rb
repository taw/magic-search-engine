# Examples from https://scryfall.com/docs/syntax
# and how they work on mtg.wtf
#
# This spec is not really maintained, and parts should probably be moved around
describe "Scryfall" do
  include_context "db"

  it "c:rg is and" do
    assert_search_equal "c:rg", "c:r AND c:g"
  end

  it "color: alias" do
    assert_search_equal "color:uw", "c:uw"
    assert_search_equal "color:red", "c:red"
    assert_search_equal "color:mardu", "c:mardu"
  end

  it "colorless" do
    # results differ due to uncards, but functionality is overall the same
    assert_search_include "c:c t:creature",
      "Abundant Maw",
      "Accomplished Automaton",
      "Barrage Tyrant",
      "Bastion Mastodon"
  end

  it "multicolor" do
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

  it "reserved" do
    # identical behaviour, at least until they abolish the damn list
    assert_count_cards "is:reserved", 571
  end

  it "meld" do
    # identical behaviour, count both parts and melded cards
    assert_count_cards "is:meld", 18
  end

  it "ft_designed" do
    # identical results
    assert_count_cards 'ft:"designed" e:m15', 15
  end

  it "ft_mishra" do
    # results differ due to uncards
    assert_search_include 'ft:"mishra"',
      "Battering Ram",
      "Ankh of Mishra",
      "Mishra's Toy Workshop"
  end

  it "creature_type" do
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

  it "tribal type" do
    # scryfall includes changelings as every creature type
    assert_search_include "t:goblin -t:creature",
      "Tarfire"
    assert_search_exclude "t:goblin -t:creature",
      "Ego Erasure"
  end

  it "banned commander" do
    # scryfall does the silly thing of counting conspiracies
    # as "banned" instead of as non-cards
    assert_search_include "banned:commander",
      "Black Lotus"
    assert_search_exclude "banned:commander",
      "Backup Plan"
  end

  it "restricted_vintage" do
    # Identical results
    assert_count_cards "restricted:vintage", 50
  end

  it "e_mm2" do
    # Identical results
    assert_count_printings "e:mm2", 249
  end

  it "b_zen" do
    # Identical results
    assert_count_printings "b:zen", 662
  end

  it "b_wwk" do
    # scryfall allows any set code to be block code
    # maybe that's a good idea
    assert_count_printings "b:wwk", 0
  end

  it "frame_future" do
    assert_search_equal "frame:future", "is:future"
  end

  it "m_gg" do
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

  it "m_2ww" do
    # same problems as m:{g}{g}
    assert_search_equal "m:2WW", "cmc=4 c:w m:2ww"
  end

  it "m_up" do
    # same problems
    assert_search_results "m:{U/P}",
      "Gitaxian Probe",
      "Mental Misstep"
  end

  it "is_split" do
    # Results differ due to uncards
    assert_search_include "is:split",
      "Alive", "Well",
      "Boom", "Bust",
      "Naughty", "Nice"
  end

  it "exact_fire" do
    assert_search_results "!Fire", "Fire"
  end

  it "exact_sift_through_sands" do
    assert_search_results '!sift through sands', "Sift Through Sands"
    assert_search_results '!"sift through sands"', "Sift Through Sands"
  end

  it "parentheses" do
    # Identical results
    assert_search_results "through (depths or sands or mists)",
      "Peer Through Depths",
      "Reach Through Mists",
      "Sift Through Sands"
  end

  it "gideon_in_any_field" do
    # identical results
    assert_search_include "ft:gideon or o:gideon or t:gideon or gideon",
      "Call the Gatewatch", # ft:
      "Gideon, Battle-Forged", # t: / name:
      "Gideon's Lawkeeper"  # name
    assert_search_exclude "ft:gideon or o:gideon or t:gideon or gideon",
      "Kytheon, Hero of Akros"
  end

  it "pow_gt_8" do
    # results differ in uncards / spoiled cards
    assert_search_include "pow>=8",
      "Akron Legionnaire",
      "Aradara Express",
      "Archdemon of Greed",
      "Brisela, Voice of Nightmares",
      "Crash of Rhinos",
      "Uktabi Kong"
  end

  it "loyalty" do
    assert_search_equal "t:planeswalker loy=3", "t:planeswalker loyalty=3"
    assert_search_include "t:planeswalker loy=3",
      "Saheeli Rai",
      "Arlinn Kord",
      "Liliana, Defiant Necromancer"
  end

  # This is hilarious, as originally
  # we had t:* system while scryfall didn't
  # Now we don't and they do...
  it "artist" do
    assert_search_include 'a:"proce"',
      "Undercity Plague",
      "Tazeem"
  end

  it "tazeem" do
    assert_search_results "tazeem",
      "Guardian of Tazeem",
      "Tazeem",
      "Tazeem Raptor",
      "Tazeem Roilmage"
  end

  it "oracle_tilde" do
    # identical results, except for spoilers
    assert_search_include 'o:"~ enters the battlefield tapped"',
      "Deadlock Trap",
      "Port Town",
      "Izzet Boilerworks"
  end

  it "pow_gt_tou" do
    # identical results except uncards and spoilers
    assert_search_include "pow>tou c:w t:creature",
      "Abzan Battle Priest"
      "Blade of the Sixth Pride"
  end

  it "border" do
    assert_search_equal "border:white t:creature", "is:white-bordered t:creature"
  end

  it "color_identity" do
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

  it "identity_but_not_color" do
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

  it "br spell standard" do
    assert_search_equal "c:br is:spell f:standard", "(c:b and c:r) is:spell f:standard"
  end

  it "ignore plusplus" do
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

  it "new frame" do
    # scryfall distinguishes "modern" and "new" frame
    # mtg.wtf and MCI treat them as same frame
    # maybe scryfall has a point here?

    # no old/future frame mythics
    # (well, that's no longer true, tons of old frame reprints)
    # is:paper st:standard tries to ignore such promos
    # (and then MAT printed Nissa, Resurgent Animist in old frame)
    assert_search_equal "is:new r:mythic is:paper st:standard -e:mat", "r:mythic is:paper st:standard -e:mat"
  end

  it "scryfall bug cmc" do
    # meld cmc is sum of part cmcs
    "c:c t:creature cmc=0".should exclude_cards("Chittering Host")
    # flip cmc equals other part, weirdly it only affect some cards, not all
    "ravager cmc=0".should return_no_cards # "Ravager of the Fells"
  end

  it "scryfall bug uncards" do
    # scryfall doesn't include uncards at all
    assert_search_include "clay", "Clay Pigeon"
  end

  it "red creatures with cmc 2 or less" do
    # scryfall currently failing due to cmc bugs
    assert_search_exclude "c:r t:creature cmc<=2",
      "Ravager of the Fells"
  end

  it "blue cmc 5" do
    # scryfall cmc errors again
    assert_search_include "c:u cmc=5",
      "Ghastly Haunting",
      "Soul Seizer"
  end

  it "common artifact" do
    # differ due to uncards
    assert_search_include "r:common t:artifact",
      "Abzan Banner",
      "Accorder's Shield", # was both common and uncommon
      "Paper Tiger" # uncard
  end

  it "oracle ignores reminder text" do
    # scryfall repeating MCI's mistakes and not cleaning up reminder text
    assert_search_include 'o:"draw" t:creature',
      "Abomination of Gudul"
    assert_search_exclude 'o:"draw" t:creature',
      "Tireless Tracker"
  end

  it "set: is alias of e:" do
    assert_search_equal "set:nph", "e:nph"
    assert_search_equal 'set:"Dragons of Tarkir"', 'e:"Dragons of Tarkir"'
  end
end

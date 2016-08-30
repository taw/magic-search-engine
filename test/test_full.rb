require_relative "test_helper"

class CardDatabaseFullTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_stats
    assert_equal 16455, @db.cards.size
    assert_equal 31290, @db.printings.size
  end

  def test_formats
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal "f:standard", "e:dtk or e:ori or e:bfz or e:ogw or e:soi or e:emn"
    assert_search_equal 'f:"ravnica block"', "e:rav or e:gp or e:di"
    assert_search_equal 'f:"ravnica block"', 'legal:"ravnica block"'
    assert_search_equal 'f:"ravnica block"', 'b:ravnica'
    assert_search_differ 'f:"mirrodin block" t:land', 'b:"mirrodin" t:land'
  end

  def test_block_codes
    assert_search_equal "b:rtr", 'b:"Return to Ravnica"'
    assert_search_equal "b:in", 'b:Invasion'
    assert_search_equal "b:som", 'b:"Scars of Mirrodin"'
    assert_search_equal "b:som", 'b:scars'
    assert_search_equal "b:mi", 'b:Mirrodin'
  end

  def test_block_special_characters
    assert_search_equal %Q[b:us], "b:urza"
    assert_search_equal %Q[b:"Urza's"], "b:urza"
  end

  def test_block_contents
    assert_search_equal "e:rtr OR e:gtc OR e:dgm", "b:rtr"
    assert_search_equal "e:in or e:ps or e:ap", 'b:Invasion'
    assert_search_equal "e:isd or e:dka or e:avr", "b:Innistrad"
    assert_search_equal "e:lw or e:mt or e:shm or e:eve", "b:lorwyn"
    assert_search_equal "e:som or e:mbs or e:nph", "b:som"
    assert_search_equal "e:mi or e:ds or e:5dn", "b:mi"
    assert_search_equal "e:som", 'e:scars'
    assert_search_equal 'f:"lorwyn-shadowmoor block"', "b:lorwyn"
  end

  def test_edition_special_characters
    assert_search_equal "e:us", %Q[e:"Urza's Saga"]
    assert_search_equal "e:us", %Q[e:"Urza’s Saga"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza's"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza’s"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza"]
  end

  def test_part
    assert_search_results "part:cmc=1 part:cmc=2", "Death", "Life", "Tear", "Wear", "What", "When", "Where", "Who", "Why"
    # Semantics of that changed
    assert_search_results "part:cmc=0 part:cmc=3 part:c:b"
  end

  def test_color_identity
    assert_search_results "ci:wu t:basic",
      "Island",
      "Plains",
      "Snow-Covered Island",
      "Snow-Covered Plains",
      "Wastes"
  end

  def test_year
    assert_search_results_printings "year=2013 t:jace",
      ["Jace, Memory Adept", "m14", "mbp"],
      ["Jace, the Mind Sculptor", "v13"]
  end

  def test_print_date
    assert_search_results %Q[print="29 september 2012"],
      "Archon of the Triumvirate",
      "Carnival Hellsteed",
      "Corpsejack Menace",
      "Grove of the Guardian",
      "Hypersonic Dragon"
  end

  def test_print
    assert_search_equal "t:planeswalker print=m12", "t:planeswalker e:m12"
    assert_search_results "t:jace print=2013", "Jace, Memory Adept", "Jace, the Mind Sculptor"
    assert_search_results "t:jace print=2012", "Jace, Architect of Thought", "Jace, Memory Adept"
    assert_search_results "t:jace firstprint=2012", "Jace, Architect of Thought"

    # This is fairly silly, as it includes prerelease promos etc.
    assert_search_results "e:ktk firstprint<ktk",
                          "Abzan Ascendancy",
                          "Act of Treason",
                          "Anafenza, the Foremost",
                          "Ankle Shanker",
                          "Arc Lightning",
                          "Avalanche Tusker",
                          "Bloodsoaked Champion",
                          "Bloodstained Mire",
                          "Butcher of the Horde",
                          "Cancel",
                          "Crackling Doom",
                          "Crater's Claws",
                          "Crippling Chill",
                          "Deflecting Palm",
                          "Despise",
                          "Dig Through Time",
                          "Dragon-Style Twins",
                          "Duneblast",
                          "Erase",
                          "Flooded Strand",
                          "Flying Crane Technique",
                          "Forest",
                          "Grim Haruspex",
                          "Hardened Scales",
                          "Herald of Anafenza",
                          "High Sentinels of Arashin",
                          "Icy Blast",
                          "Incremental Growth",
                          "Island",
                          "Ivorytusk Fortress",
                          "Jeering Instigator",
                          "Jeskai Ascendancy",
                          "Jeskai Elder",
                          "Kheru Lich Lord",
                          "Mardu Ascendancy",
                          "Mardu Heart-Piercer",
                          "Master of Pearls",
                          "Mountain",
                          "Mystic Monastery",
                          "Narset, Enlightened Master",
                          "Naturalize",
                          "Necropolis Fiend",
                          "Nomad Outpost",
                          "Plains",
                          "Polluted Delta",
                          "Rakshasa Vizier",
                          "Rattleclaw Mystic",
                          "Sage of the Inward Eye",
                          "Seek the Horizon",
                          "Shatter",
                          "Sidisi, Brood Tyrant",
                          "Siege Rhino",
                          "Smite the Monstrous",
                          "Sultai Ascendancy",
                          "Surrak Dragonclaw",
                          "Swamp",
                          "Temur Ascendancy",
                          "Thousand Winds",
                          "Trail of Mystery",
                          "Trap Essence",
                          "Trumpet Blast",
                          "Utter End",
                          "Villainous Wealth",
                          "Windstorm",
                          "Windswept Heath",
                          "Wooded Foothills",
                          "Zurgo Helmsmasher"

    assert_search_results "e:ktk lastprint>ktk",
                          "Act of Treason",
                          "Ainok Tracker",
                          "Altar of the Brood",
                          "Arc Lightning",
                          "Bloodfell Caves",
                          "Bloodstained Mire",
                          "Blossoming Sands",
                          "Briber's Purse",
                          "Burn Away",
                          "Debilitating Injury",
                          "Disdainful Stroke",
                          "Dismal Backwater",
                          "Dragonscale Boon",
                          "Dutiful Return",
                          "Flooded Strand",
                          "Forest",
                          "Ghostfire Blade",
                          "Grim Haruspex",
                          "Hordeling Outburst",
                          "Incremental Growth",
                          "Island",
                          "Jeering Instigator",
                          "Jungle Hollow",
                          "Kill Shot",
                          "Mountain",
                          "Mystic of the Hidden Way",
                          "Naturalize",
                          "Plains",
                          "Polluted Delta",
                          "Ride Down",
                          "Rugged Highlands",
                          "Ruthless Ripper",
                          "Scoured Barrens",
                          "Shatter",
                          "Smite the Monstrous",
                          "Sultai Charm",
                          "Summit Prowler",
                          "Suspension Field",
                          "Swamp",
                          "Swiftwater Cliffs",
                          "Thornwood Falls",
                          "Throttle",
                          "Tormenting Voice",
                          "Tranquil Cove",
                          "Trumpet Blast",
                          "Watcher of the Roost",
                          "Weave Fate",
                          "Wind-Scarred Crag",
                          "Windstorm",
                          "Windswept Heath",
                          "Wooded Foothills"
  end

  def test_firstprint
    assert_search_results "t:planeswalker firstprint=m12", "Chandra, the Firebrand", "Garruk, Primal Hunter", "Jace, Memory Adept"
  end

  def test_lastprint
    assert_search_results "t:planeswalker lastprint<=roe", "Chandra Ablaze", "Sarkhan the Mad"
    assert_search_results "t:planeswalker lastprint<=2011",
      "Ajani Goldmane", "Ajani Vengeant", "Chandra Ablaze", "Elspeth Tirel",
      "Garruk Relentless", "Garruk, the Veil-Cursed", "Gideon Jura", "Liliana of the Veil",
      "Nissa Revane", "Sarkhan the Mad", "Sorin Markov", "Tezzeret, Agent of Bolas"
  end

  def test_time_travel_basic
    assert_search_equal "time:lw t:planeswalker", "e:lw t:planeswalker"
    assert_search_results "time:wwk t:jace", "Jace Beleren", "Jace, the Mind Sculptor"
  end

  def test_time_travel_printed
    assert_search_equal "time:lw t:planeswalker", "e:lw t:planeswalker"
    assert_search_results "t:jace lastprint=wwk"
    assert_search_results "t:jace print=vma", "Jace, the Mind Sculptor"
    assert_search_results "time:nph t:jace lastprint=wwk", "Jace, the Mind Sculptor"
    assert_search_results "time:nph t:jace print=vma"
  end

  def test_time_travel_standard_legal_reprints_activate_in_block
    assert_search_results 'f:"return to ravnica block" naturalize', "Naturalize"
    assert_search_results 'time:rtr f:"return to ravnica block" naturalize'
    assert_search_results 'time:gtc f:"return to ravnica block" naturalize', "Naturalize"
    assert_search_results 'time:dgm f:"return to ravnica block" naturalize', "Naturalize"
  end

  def test_time_travel_standard_legal_reprints_activate_in_modern
    assert_search_results "f:legacy rancor", "Rancor"
    assert_search_results "f:modern rancor", "Rancor"
    assert_search_results "time:m11 f:legacy rancor", "Rancor"
    assert_search_results "time:m11 f:modern rancor"
  end

  def test_time_travel_eternal_formats_accept_all_sets
    assert_search_equal "f:legacy t:jace", "t:jace"
    assert_search_equal "f:legacy time:nph t:jace", "time:nph t:jace"
    assert_search_equal "f:vintage t:jace", "t:jace"
    assert_search_equal "f:vintage time:nph t:jace", "time:nph t:jace"
    assert_search_equal "f:commander t:jace", "t:jace"
    assert_search_equal "f:commander time:nph t:jace", "time:nph t:jace"
  end

  def test_sort
    assert_search_results "t:chandra sort:name",
      "Chandra Ablaze",
      "Chandra Nalaar",
      "Chandra, Flamecaller",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, the Firebrand"
    assert_search_results "t:chandra sort:new",
      "Chandra, Flamecaller",
      "Chandra, Roaring Flame",
      "Chandra, Pyromaster",
      "Chandra, the Firebrand",
      "Chandra Nalaar",
      "Chandra Ablaze"
    # Jace v Chandra printing of Chandra Nalaar changes order
    assert_search_results "t:chandra sort:newall",
      "Chandra, Flamecaller",
      "Chandra, Roaring Flame",
      "Chandra Nalaar",
      "Chandra, Pyromaster",
      "Chandra, the Firebrand",
      "Chandra Ablaze"
    assert_search_results "t:chandra sort:old",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, the Firebrand",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Flamecaller"
    assert_search_results "t:chandra sort:oldall",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, the Firebrand",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Flamecaller"
    assert_search_results "t:chandra sort:cmc",
      "Chandra Ablaze",
      "Chandra Nalaar",
      "Chandra, Flamecaller",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, the Firebrand"
  end

  def test_alt_rebecca_guay
    assert_search_results %Q[a:"rebecca guay" alt:(-a:"rebecca guay")],
      "Ancestral Memories",
      "Angelic Page",
      "Angelic Wall",
      "Auramancer",
      "Bitterblossom",
      "Boomerang",
      "Channel",
      "Coral Merfolk",
      "Dark Banishing",
      "Dark Ritual",
      "Elven Cache",
      "Elvish Lyrist",
      "Elvish Piper",
      "Mana Breach",
      "Memory Lapse",
      "Mountain",
      "Mulch",
      "Path to Exile",
      "Phantom Monster",
      "Plains",
      "Sea Sprite",
      "Serra Angel",
      "Spellstutter Sprite",
      "Taunting Elf",
      "Thoughtleech",
      "Twiddle",
      "Wall of Wood",
      "Wanderlust",
      "Wood Elves"
  end

  def test_alt_test_of_time
    assert_search_results "year=1993 alt:year=2015",
      "Basalt Monolith",
      "Counterspell",
      "Dark Ritual",
      "Desert Twister",
      "Disenchant",
      "Earthquake",
      "Forest",
      "Island",
      "Jayemdae Tome",
      "Lightning Bolt",
      "Mahamoti Djinn",
      "Mountain",
      "Nightmare",
      "Plains",
      "Sengir Vampire",
      "Serra Angel",
      "Shatter",
      "Shivan Dragon",
      "Sol Ring",
      "Spell Blast",
      "Swamp",
      "Tranquility"
  end

  def test_alt_rarity
    assert_search_include "r:common alt:r:uncommon", "Doom Blade"
    assert_search_results "r:common alt:r:mythic",
      "Cabal Ritual",
      "Chainer's Edict",
      "Dark Ritual",
      "Desert",
      "Fyndhorn Elves",
      "Hymn to Tourach",
      "Impulse",
      "Kird Ape",
      "Lotus Petal"
  end

  def test_pow_special
    assert_search_equal "pow=1+*", "pow=*+1"
    assert_search_include "pow=*", "Krovikan Mist"
    assert_search_results "pow=1+*",
      "Gaea's Avenger", "Lost Order of Jarkeld", "Haunting Apparition", "Mwonvuli Ooze", "Allosaurus Rider"
    assert_search_results "pow=2+*",
      "Angry Mob", "Aysen Crusader"
    assert_search_equal "pow>*", "pow>=1+*"
    assert_search_equal "pow>1+*", "pow>=2+*"
    assert_search_equal "pow>1+*", "pow=2+*"
    assert_search_equal "pow=*2", "pow=*²"
    assert_search_results "pow=*2",
      "S.N.O.T."
  end

  def test_tou_special
    # Mostly same as power except 7-*
    assert_search_results "tou=7-*", "Shapeshifter"
    assert_search_results "tou>8-*"
    assert_search_results "tou>2-*", "Shapeshifter"
    assert_search_results "tou>8-*"
    assert_search_results "tou<=8-*", "Shapeshifter"
    assert_search_results "tou<=2-*"
  end

  def test_error_handling
    # Empty search returns all non-extras
    assert_count_results "", 16197
    assert_count_results "sort:new", 16197
    assert_count_results "is:spell or t:land", 16197
    assert_count_results "time:3000", 16197
    assert_count_results %Q[time:"battle for homelands"], 16197
    assert_count_results "time:1000", 0
    assert_search_equal %Q[time:"battle for homelands" f:standard], "f:standard"
  end

  def test_is_promo
    # mtgjson has different idea what's promo,
    # mci returns 1054 cards
    assert_count_results "is:promo", 1047
  end

  def test_is_funny
    assert_search_results "abyss is:funny", "Zzzyxas's Abyss"
    assert_search_results "abyss not:funny",
      "Abyssal Gatekeeper",
      "Abyssal Horror",
      "Abyssal Hunter",
      "Abyssal Nightstalker",
      "Abyssal Nocturnus",
      "Abyssal Persecutor",
      "Abyssal Specter",
      "Magus of the Abyss",
      "Reaper from the Abyss",
      "The Abyss"
    assert_search_results "snow is:funny", "Snow Mercy"
    assert_search_results "tiger is:funny", "Paper Tiger", "Stocking Tiger"
  end

  def test_mana_variables
    assert_search_equal "b:ravnica guildmage mana=hh", "b:ravnica guildmage c:m cmc=2"
    assert_search_equal "e:rtr mana=h", "e:rtr c:m cmc=1"
    assert_search_results "mana>mmmmm",
      "B.F.M. (Big Furry Monster)",
      "Khalni Hydra",
      "Primalcrux"
    assert_count_results "e:ktk (charm OR ascendancy) mana=mno", 10
    assert_count_results "e:ktk mana=mno", 15
    assert_search_results "mana=mmnnnoo",
      "Brilliant Ultimatum",
      "Clarion Ultimatum",
      "Cruel Ultimatum",
      "Titanic Ultimatum",
      "Violent Ultimatum"
    assert_search_results "mana=wwmmmnn",
      "Brilliant Ultimatum",
      "Titanic Ultimatum"
    assert_search_equal "mana=mmnnnoo", "mana=nnooomm"
    assert_search_equal "mana>nnnnn", "mana>ooooo"
    assert_search_equal "mana=mno", "mana={m}{n}{o}"
    assert_search_equal "mana=mmn", "mana=mnn"
    assert_search_equal "mana=mmn", "mana>=mnn mana <=mmn"
    assert_count_results "mana>=mh", 15
    assert_search_results "mana=mh",
      "Bant Sureblade",
      "Crystallization",
      "Esper Stormblade",
      "Grixis Grimblade",
      "Jund Hackblade",
      "Naya Hushblade",
      "Sangrite Backlash",
      "Thopter Foundry",
      "Trace of Abundance"
    assert_search_equal "mana=mh", "mana={m}{h}"
    assert_search_equal "mana={w}{m}", "mana={w}{u} OR mana={w}{b} OR mana={w}{r} OR mana={w}{g}"
    assert_search_equal "mana={m}{h}", "mana={w}{h} OR mana={u}{h} OR mana={b}{h} OR mana={r}{h} OR mana={g}{h}"
    # Only {w}{u/b} of these exists, no cards have hybrid and nonhybrid of same color in mana cost yet
    assert_search_equal "mana={m}{w/b}", "mana={w}{w/b} OR mana={u}{w/b} OR mana={b}{w/b} OR mana={r}{w/b} OR mana={g}{w/b}"
  end

  def test_stemming
    assert_search_equal "vision", "visions"
  end

  def test_comma_separated_set_list
    assert_search_equal "e:cmd or e:cma or e:c13 or e:c14 or e:c15", "e:cmd,cma,c13,c14,c15"
    assert_search_equal "st:cmd -alt:-st:cmd", "e:cmd,cma,c13,c14,c15 -alt:-e:cmd,cma,c13,c14,c15"
  end

  def test_command_separated_block_list
    assert_search_equal "b:isd or b:soi", "b:isd,soi"
  end
end

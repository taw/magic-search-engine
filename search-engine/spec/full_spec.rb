describe "Full Database Test" do
  include_context "db"

  it "stats" do
    db.number_of_cards.should eq(18689)
    db.number_of_printings.should eq(36868)
  end

  it "block codes" do
    assert_search_equal "b:rtr", 'b:"Return to Ravnica"'
    assert_search_equal "b:in", 'b:Invasion'
    assert_search_equal "b:som", 'b:"Scars of Mirrodin"'
    assert_search_equal "b:som", 'b:scars'
    assert_search_equal "b:mi", 'b:Mirrodin'
  end

  it "block special characters" do
    assert_search_equal %Q[b:us], "b:urza"
    assert_search_equal %Q[b:"Urza's"], "b:urza"
  end

  it "block contents" do
    assert_search_equal "e:rtr OR e:gtc OR e:dgm", "b:rtr"
    assert_search_equal "e:in or e:ps or e:ap", "b:Invasion"
    assert_search_equal "e:isd or e:dka or e:avr", "b:Innistrad"
    assert_search_equal "e:lw or e:mt or e:shm or e:eve", "b:lorwyn"
    assert_search_equal "e:som or e:mbs or e:nph", "b:som"
    assert_search_equal "e:mi or e:ds or e:5dn", "b:mi"
    assert_search_equal "e:som", "e:scars"
    assert_search_equal_cards 'f:"lorwyn shadowmoor block"', "b:lorwyn"
    # Fake blocks
    assert_search_equal "e:dom", "b:dom"
    # Gatherer codes
    assert_search_equal 'b:lw', "b:lrw"
    assert_search_equal 'b:mi', "b:mrd"
    assert_search_equal 'b:mr', "b:mir"
  end

  it "edition special characters" do
    assert_search_equal "e:us", %Q[e:"Urza's Saga"]
    assert_search_equal "e:us", %Q[e:"Urza’s Saga"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza's"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza’s"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza"]
  end

  it "part" do
    assert_search_results "part:cmc=1 part:cmc=2",
      "Death", "Life",
      "Tear", "Wear",
      "What", "When", "Where", "Who", "Why",
      "Failure", "Comply",
      "Heaven", "Earth",
      "Claim", "Fame",
      "Appeal", "Authority"
    # Semantics of that changed
    assert_search_results "part:cmc=0 part:cmc=3 part:c:b"
  end

  it "color identity" do
    assert_search_results "ci:wu t:basic",
      "Island",
      "Plains",
      "Snow-Covered Island",
      "Snow-Covered Plains",
      "Wastes"
  end

  it "year" do
    Query.new("year=2013 t:jace").search(db).card_names_and_set_codes.should eq([
      ["Jace, Memory Adept", "m14", "mbp"],
      ["Jace, the Mind Sculptor", "v13"],
    ])
  end

  it "print date" do
    assert_search_results %Q[print="29 september 2012"],
      "Archon of the Triumvirate",
      "Carnival Hellsteed",
      "Corpsejack Menace",
      "Grove of the Guardian",
      "Hypersonic Dragon"
    assert_search_equal %Q[print="29 september 2012"], %Q[print=2012-09-29]
  end

  it "print" do
    assert_search_equal "t:planeswalker print=m12", "t:planeswalker e:m12"
    assert_search_results "t:jace print=2013", "Jace, Memory Adept", "Jace, the Mind Sculptor"
    assert_search_results "t:jace print=2012", "Jace, Architect of Thought", "Jace, Memory Adept"
    assert_search_results "t:jace firstprint=2012", "Jace, Architect of Thought"

    # This is fairly silly, as it includes prerelease promos etc.
    assert_search_results "e:soi firstprint<soi",
      "Catalog",
      "Compelling Deterrence",
      "Dead Weight",
      "Eerie Interlude",
      "Fiery Temper",
      "Forest",
      "Ghostly Wings",
      "Gloomwidow",
      "Groundskeeper",
      "Island",
      "Lightning Axe",
      "Macabre Waltz",
      "Mad Prophet",
      "Magmatic Chasm",
      "Mindwrack Demon",
      "Mountain",
      "Plains",
      "Pore Over the Pages",
      "Puncturing Light",
      "Reckless Scholar",
      "Swamp",
      "Throttle",
      "Tooth Collector",
      "Topplegeist",
      "Tormenting Voice",
      "Unruly Mob"

    assert_search_results "e:soi lastprint>soi",
      "Aim High",
      "Archangel Avacyn",
      "Arlinn Kord",
      "Arlinn, Embraced by the Moon",
      "Avacyn, the Purifier",
      "Dauntless Cathar",
      "Dual Shot",
      "Engulf the Shore",
      "Explosive Apparatus",
      "Forest",
      "Forsaken Sanctuary",
      "Foul Orchard",
      "Grotesque Mutation",
      "Highland Lake",
      "Island",
      "Macabre Waltz",
      "Mountain",
      "Plains",
      "Pyre Hound",
      "Rabid Bite",
      "Reckless Scholar",
      "Rush of Adrenaline",
      "Sleep Paralysis",
      "Stone Quarry",
      "Swamp",
      "Thornhide Wolves",
      "Tormenting Voice",
      "Triskaidekaphobia",
      "Uncaged Fury",
      "Vampire Noble",
      "Vessel of Nascency",
      "Woodland Stream"
  end

  it "firstprint" do
    assert_search_results "t:planeswalker firstprint=m12", "Chandra, the Firebrand", "Garruk, Primal Hunter", "Jace, Memory Adept"
  end

  it "lastprint" do
    assert_search_results "t:planeswalker lastprint<=roe", "Chandra Ablaze", "Sarkhan the Mad"
    assert_search_results "t:planeswalker lastprint<=2011",
      "Ajani Goldmane", "Ajani Vengeant", "Chandra Ablaze", "Elspeth Tirel",
      "Nissa Revane", "Sarkhan the Mad", "Sorin Markov", "Tezzeret, Agent of Bolas"
  end

  it "alt Rebecca Guay" do
    assert_search_results %Q[a:"rebecca guay" alt:(-a:"rebecca guay")],
      "Ancestral Memories",
      "Angelic Page",
      "Angelic Wall",
      "Auramancer",
      "Aven Mindcensor",
      "Bitterblossom",
      "Boomerang",
      "Channel",
      "Coral Merfolk",
      "Dark Banishing",
      "Dark Ritual",
      "Elven Cache",
      "Elvish Lyrist",
      "Elvish Piper",
      "Forest",
      "Gaea's Blessing",
      "Island",
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
      "Swamp",
      "Taunting Elf",
      "Thoughtleech",
      "Twiddle",
      "Wall of Wood",
      "Wanderlust",
      "Wood Elves"
  end

  it "alt test of time" do
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

  it "alt rarity" do
    assert_search_include "r:common alt:r:uncommon", "Doom Blade"
    assert_search_results "r:common alt:r:mythic",
      "Cabal Ritual",
      "Chainer's Edict",
      "Dark Ritual",
      "Delver of Secrets",
      "Desert",
      "Fyndhorn Elves",
      "Hymn to Tourach",
      "Impulse",
      "Insectile Aberration",
      "Kird Ape",
      "Lotus Petal"
  end

  it "pow:special" do
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

  it "loy:special" do
    assert_search_results "loy=0"
    assert_search_equal "loy=x", "loy=X"
    assert_search_results "loy=x", "Nissa, Steward of Elements"
  end

  it "tou:special" do
    # Mostly same as power except 7-*
    assert_search_results "tou=7-*", "Shapeshifter"
    assert_search_results "tou>8-*"
    assert_search_results "tou>2-*", "Shapeshifter"
    assert_search_results "tou>8-*"
    assert_search_results "tou<=8-*", "Shapeshifter"
    assert_search_results "tou<=2-*"
  end

  it "is:promo" do
    # it's not totally clear what counts as "promo"
    # and different engines return different results
    # It might be a good idea to sort out edge cases someday
    assert_count_printings "is:promo", 1198
  end

  it "is:funny" do
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

  it "mana variables" do
    assert_search_equal "b:ravnica guildmage mana=hh", "b:ravnica guildmage c:m cmc=2"
    assert_search_equal "e:rtr mana=h", "e:rtr c:m cmc=1"
    assert_search_results "mana>mmmmm",
      "B.F.M. (Big Furry Monster)",
      "B.F.M. (Big Furry Monster, Right Side)",
      "Khalni Hydra",
      "Primalcrux"
    assert_count_cards "e:ktk (charm OR ascendancy) mana=mno", 10
    assert_count_cards "e:ktk mana=mno", 15
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
    assert_count_cards "mana>=mh", 15
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

  it "stemming" do
    assert_search_equal "vision", "visions"
  end

  it "comma separated set list" do
    assert_search_equal "e:cmd or e:cm1 or e:c13 or e:c14 or e:c15 or e:c16 or e:c17 or e:cma or e:cm2", "e:cmd,cm1,c13,c14,c15,c16,c17,cma,cm2"
    assert_search_equal "st:cmd -alt:-st:cmd", "e:cmd,cm1,c13,c14,c15,c16,c17,cma,cm2 -alt:-e:cmd,cm1,c13,c14,c15,c16,c17,cma,cm2"
  end

  it "comma separated block list" do
    assert_search_equal "b:isd or b:soi", "b:isd,soi"
  end

  it "legal everywhere" do
    legality_information("Island").should be_legal_everywhere
    legality_information("Giant Spider").should_not be_legal_everywhere
    legality_information("Birthing Pod").should_not be_legal_everywhere
    legality_information("Naya").should_not be_legal_everywhere
    legality_information("Backup Plan").should_not be_legal_everywhere
  end

  it "legal nowhere" do
    legality_information("Island").should_not be_legal_nowhere
    legality_information("Giant Spider").should_not be_legal_nowhere
    legality_information("Birthing Pod").should_not be_legal_nowhere
    legality_information("Naya").should be_legal_nowhere
    legality_information("Backup Plan").should be_legal_nowhere
  end

  it "is commander" do
    # Some C14 commanders got reprited
    assert_search_equal_cards "is:commander", "(is:primary t:legendary t:creature) OR (t:planeswalker e:c14,bbd)"
  end

  # Bugfix
  it "cm1/cma set codes" do
    "e:cm1".should have_count_printings(18)
    "e:cma".should have_count_printings(320)
  end

  it "gtw/wpn/grc set codes" do
    "e:gtw".should have_count_printings(20)
    "e:wpn".should have_count_printings(45)
    "e:grc".should have_count_printings(0)
  end

  it "is:permanent" do
    assert_search_equal "is:permanent", "not (t:instant or t:sorcery or t:plane or t:scheme or t:phenomenon or t:conspiracy or t:vanguard)"
  end

  it "promo and special" do
    # Are promo basics really of basic rarity?
    assert_search_equal "t:basic is:promo", "t:basic r:special"
    assert_search_equal "t:basic", "(r:basic -t:urza's) or (t:basic r:special) or (t:basic e:an)"
    assert_search_results "is:promo -r:special -e:ugin"
    assert_search_results %Q[r:special -is:promo -st:masterpiece -t:vanguard -e:anthologies -e:tsts -e:"clash pack" -e:vma -e:mgbc],
      "Giant Trap Door Spider",
      "Super Secret Tech",
      "Tazeem"
  end

  it "all planeswalkers are legendary" do
    assert_search_results "t:planeswalker -t:legendary"
  end

  it "frame:" do
    assert_search_equal "frame:modern OR frame:m15", "frame:new"
    assert_search_differ "frame:modern", "frame:new"
    assert_search_differ "frame:m15", "frame:new"
  end

  it "is:unique" do
    number_of_unique_cards = db.cards.values.count{|c| c.printings.size == 1}
    assert_count_cards "is:unique", number_of_unique_cards
    assert_search_equal "is:unique", "++ is:unique"
    assert_search_equal "not:unique", "-is:unique"
  end

  it "is:historic" do
    assert_search_equal "is:historic", "t:artifact or t:legendary or t:saga"
  end

  it "Oracle unicode" do
    assert_search_equal %Q[o:"Lim-Dûl"], %Q[o:"Lim-Dul"]
    assert_search_results %Q[o:"Lim-Dul"],
      "Lim-Dûl's Cohort",
      "Lim-Dûl's Hex",
      "Lim-Dûl's High Guard",
      "Lim-Dûl's Paladin",
      "Oath of Lim-Dûl"
    lim_duls_cohort = db.search("Lim-Dûl's Cohort").printings[0]
    lim_duls_cohort.text.should eq("Whenever Lim-Dûl's Cohort blocks or becomes blocked by a creature, that creature can't be regenerated this turn.")
  end

  it "Non-alphanumeric characters in set names are ignored and 's is normalized" do
    assert_search_equal %Q[e:"Elves vs Inventors"], %Q[e:"Elves vs. Inventors"]
    assert_search_equal %Q[e:"From the Vault: Transform"], %Q[e:"From the Vault Transform"]
    assert_search_equal %Q[e:"Duel Decks: Nissa vs. Ob Nixilis"], %Q[e:"Duel Decks Nissa vs Ob Nixilis"]
    assert_search_equal %Q[e:"Ugin's Fate promos"], %Q[e:"Ugin Fate promos"]
    assert_search_equal %Q[e:"Ugin's Fate promos"], %Q[e:"Ugins Fate promos"]
    assert_search_equal %Q[e:"Duel Decks Anthology, Divine vs. Demonic"], %Q[e:"Duel Decks Anthology Divine vs Demonic"]
    assert_search_equal %Q[e:"Magic: The Gathering—Conspiracy"], %Q[e:"Magic The Gathering Conspiracy"]
  end

  def legality_information(name, date=nil)
    db.cards[name.downcase].legality_information(date)
  end
end

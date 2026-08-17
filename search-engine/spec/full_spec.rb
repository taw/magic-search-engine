describe "Full Database Test" do
  include_context "db"

  it "is:promo" do
    # it's not totally clear what counts as "promo"
    # and different engines return different results
    # It might be a good idea to sort out edge cases someday
    assert_search_equal "is:promo", "st:promo"
  end

  it "edition special characters" do
    assert_search_equal "e:us", %[e:"Urza's Saga"]
    assert_search_equal "e:us", %[e:"Urza’s Saga"]
    assert_search_equal "e:us or e:ul or e:ud or e:pusg or e:puds or e:pulg", %[e:"urza's"]
    assert_search_equal "e:us or e:ul or e:ud or e:pusg or e:puds or e:pulg", %[e:"urza’s"]
    assert_search_equal "e:us or e:ul or e:ud or e:pusg or e:puds or e:pulg", %[e:"urza"]
  end

  it "part" do
    assert_search_results "part:cmc=1 part:cmc=2",
      "Appeal", "Authority",
      "Bloodline Recollector", "Ancestral Craving",
      "Bofur, Reliable Guardian", "Concerted Care",
      "Callous Sell-Sword", "Burn Together",
      "Claim", "Fame",
      "Crescendo Conductor", "Boltwave (Prepared)",
      "Curious Pair", "Treats to Share",
      "Death", "Life",
      "Elite Interceptor", "Rejoinder",
      "Embereth Shieldbreaker", "Battle Display",
      "Emeritus of Conflict", "Lightning Bolt (Prepared)",
      "Faerie Guidemother", "Gift of the Fae",
      "Failure", "Comply",
      "Fear (split card)", "Loathing",
      "Ghost Lantern", "Bind Spirit",
      "Goblin Glasswright", "Craft with Pride",
      "Heaven", "Earth",
      "Infirmary Healer", "Stream of Life (Prepared)",
      "Kellan, Daring Traveler", "Journey On",
      "Leech Collector", "Bloodletting",
      "Most Decrepit Old Bird", "Speak Secrets",
      "Paradox Shaper", "Omit Variables",
      "Pollen-Shield Hare", "Hare Raising",
      "Rimrock Knight", "Boulder Rush",
      "Shepherd of the Flock", "Usher to Safety",
      "Smelt (CMB1)", "Herd", "Saw (CMB1)",
      "Smitten Swordmaster", "Curry Favor",
      "Studious First-Year", "Rampant Growth (Prepared)",
      "Tear", "Wear",
      "Their", "There", "They're",
      "Vigorbloom Vanguard", "Seed Suture",
      "What", "When", "Where", "Who", "Why"
    # Semantics of that changed
    # it used to match a lot of double-faced cards
    # then it all disappeared as DFCs share cmc
    # but then MDFCs came out using previous rules
    assert_search_results "part:cmc=0 part:cmc=3 part:c:b",
      "Agadeem, the Undercrypt",
      "Agadeem's Awakening",
      "Blackbloom Bog",
      "Blackbloom Rogue",
      "Boggart Bog",
      "Boggart Trawler",
      "Midgar, City of Mako",
      "Pelakka Caverns",
      "Pelakka Predation",
      "Reactor Raid"
  end

  it "color identity" do
    assert_search_results "ci:wu t:basic",
      "Barry's Land",
      "Island",
      "Omnipresent Impostor",
      "Plains",
      "Snow-Covered Island",
      "Snow-Covered Plains",
      "Snow-Covered Wastes",
      "Wastes"
  end

  it "year" do
    Query.new("year=2013 t:jace").search(db).card_names_and_set_codes.should eq([
      ["Jace, Memory Adept", "m14", "psdc"],
      ["Jace, the Mind Sculptor", "v13"],
    ])
  end

  it "print date" do
    # M13 prerelease
    assert_search_results %[print="12 july 2012"],
      "Cathedral of War",
      "Magmaquake",
      "Mwonvuli Beast Tracker",
      "Staff of Nin",
      "Xathrid Gorgon"
    assert_search_equal %[print="12 july 2012"], %[print=2012-07-12]
  end

  # Dates are compared at the precision they were typed at, so a yyyy-mm
  # query means the whole month, not its first day
  it "print month" do
    assert_search_results "t:planeswalker print=2012-07",
      "Ajani, Caller of the Pride",
      "Chandra, the Firebrand",
      "Garruk, Primal Hunter",
      "Jace, Memory Adept",
      "Liliana of the Dark Realms",
      "Nicol Bolas, Planeswalker"

    assert_search_equal "t:jace print=2012-7", "t:jace print=2012-07"
    assert_search_equal "t:jace print=2012-07", "t:jace print>=2012-07-01 print<=2012-07-31"
    assert_search_equal "t:jace print>=2012-07", "t:jace print>=2012-07-01"
    assert_search_equal "t:jace print>2012-07", "t:jace print>2012-07-31"
    assert_search_equal "t:jace print<=2012-07", "t:jace print<=2012-07-31"
    assert_search_equal "t:jace print<2012-07", "t:jace print<2012-07-01"
  end

  it "print date that isn't a date" do
    # A month out of range looks like a date until it's parsed, and used to
    # raise Date::Error instead of warning
    ["lolwtf", "2012-13", "2012-00"].each do |date|
      results = db.search("print>=#{date}")
      results.warnings.to_a.should eq([%[Doesn't look like correct date, ignored: "#{date}"]])
      results.printings.size.should eq(db.printings.size)
    end
  end

  # Digital only cards with their bullshit release dates are really messing up with this test
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
      "Rise from the Tides", # mtgjson error
      "Swamp",
      "Throttle",
      "Tooth Collector",
      "Topplegeist",
      "Tormenting Voice",
      "Unruly Mob"

    assert_search_equal "in:soi lastprint>soi", "in:soi -lastprint<=soi"
  end

  it "firstprint" do
    assert_search_results "t:planeswalker firstprint=m12",
      "Chandra, the Firebrand",
      "Garruk, Primal Hunter",
      "Jace, Memory Adept"
  end

  it "lastprint" do
    assert_search_results "t:planeswalker lastprint<=roe",
      "Chandra Ablaze"
    assert_search_results "t:planeswalker lastprint<=2011",
      "Chandra Ablaze"
  end

  it "alt a" do
    assert_search_results %[a:"Randy Elliott" alt:(-a:"Randy Elliott")],
      "Island",
      "Paladin en-Vec",
      "Peace of Mind"
  end

  it "alt test of time" do
    assert_search_results "year=1993 alt:(year=2015 -is:digital)",
      "Basalt Monolith",
      "Desert Twister",
      "Earthquake",
      "Forest",
      "Island",
      "Jayemdae Tome",
      "Lightning Bolt",
      "Mahamoti Djinn",
      "Mountain",
      "Mox Emerald",
      "Nightmare",
      "Plains",
      "Sengir Vampire",
      "Serra Angel",
      "Shivan Dragon",
      "Sol Ring",
      "Swamp",
      "Tundra"
  end

  it "alt rarity" do
    assert_search_include "r:common alt:r:uncommon", "Doom Blade"
    assert_search_include "r:common alt:r:mythic",
      "Bojuka Bog",
      "Cabal Ritual",
      "Dark Ritual",
      "Delver of Secrets",
      "Desert",
      "Exhume",
      "Fyndhorn Elves",
      "Hymn to Tourach",
      "Impulse",
      "Insectile Aberration",
      "Kird Ape",
      "Lotus Petal",
      "Rhystic Study",
      "Shock",
      "Sol Ring"
  end

  it "is:funny" do
    assert_search_results "abyss is:funny", "Zzzyxas's Abyss"
    assert_search_results "abyss not:funny",
      "Abyssal Gatekeeper",
      "Abyssal Gorestalker",
      "Abyssal Harvester",
      "Abyssal Horror",
      "Abyssal Hunter",
      "Abyssal Nightstalker",
      "Abyssal Nocturnus",
      "Abyssal Persecutor",
      "Abyssal Specter",
      "Gale, Abyssal Conduit",
      "Magus of the Abyss",
      "Peer into the Abyss",
      "Reaper from the Abyss",
      "The Abyss",
      "Tiger Shark, Abyssal Hunter"
    assert_search_results "snow is:funny", "Snow Mercy", "Princess Snowfall"
    assert_search_results "tiger is:funny", "Paper Tiger", "Stocking Tiger"
  end

  it "stemming" do
    assert_search_equal "vision", "visions"
  end

  it "comma separated set list" do
    assert_search_equal "e:cmd or e:cm1 or e:c13 or e:c14 or e:c15 or e:c16 or e:c17 or e:c18 or e:cma or e:cm2", "e:cmd,cm1,c13,c14,c15,c16,c17,c18,cma,cm2"
    assert_search_equal "st:portal -alt:-st:portal", "e:por,p02,ptk -alt:-e:por,p02,ptk"
  end

  it "r:special" do
    assert_search_equal "r:special -e:tsr,plst,pewk,ovnt,olgc,unk", "(Super Secret Tech) or (e:vma r:special) or (e:tsb) or (Prismatic Piper) or (Faceless One) or e:mps,mp2"
    assert_count_cards "r:special e:tsr", 121
  end

  it "all planeswalkers are legendary (except CMB1 and MB2)" do
    assert_search_results "t:planeswalker -t:legendary", "Personal Decoy", "Wrenn and One"
  end

  it "is:unique" do
    number_of_unique_cards = db.cards.values.count { |c| c.printings.size == 1 }
    assert_count_cards "is:unique", number_of_unique_cards
    assert_search_equal "is:unique", "++ is:unique"
    assert_search_equal "not:unique", "-is:unique"
  end

  # This test got messed up by latest Oracle changes replacing text by "this creature" etc.
  it "Oracle unicode" do
    assert_search_equal %[o:"Éomer"], %[o:"Eomer"]
    assert_search_results %[o:"Eomer"],
      "Éomer of the Riddermark",
      "Éomer, King of Rohan"
    eomer = db.search("Éomer of the Riddermark").printings[0]
    eomer.text.should eq("Haste\nWhenever Éomer attacks, if you control a creature with the greatest power among creatures on the battlefield, create a 1/1 white Human Soldier creature token.")
  end

  it "artist unicode" do
    assert_search_equal %[a:"baǵa"], %[a:"baga"]
    assert_search_equal %[a:Snõddy], %[a:snoddy]
    assert_search_equal %[a:Véronique], %[a:Veronique]
    assert_search_equal %[a:Ćeran], %[a:ceran]
  end

  it "Non-alphanumeric characters in set names are ignored and 's is normalized" do
    assert_search_equal %[e:"Elves vs Inventors"], %[e:"Elves vs. Inventors"]
    assert_search_equal %[e:"From the Vault: Transform"], %[e:"From the Vault Transform"]
    assert_search_equal %[e:"Duel Decks: Nissa vs. Ob Nixilis"], %[e:"Duel Decks Nissa vs Ob Nixilis"]
    assert_search_equal %[e:"Ugin's Fate"], %[e:"Ugin Fate"]
    assert_search_equal %[e:"Ugin's Fate"], %[e:"Ugins Fate"]
    assert_search_equal %[e:"Duel Decks Anthology, Divine vs. Demonic"], %[e:"Duel Decks Anthology Divine vs Demonic"]
  end

  it "is:custom" do
    # is:custom is used only by forks, there shouldn't be any custom cards in the database
    assert_search_results "is:custom"
  end

  it "is:mainfront" do
    # Not the same for split cards
    assert_search_equal "-is:split is:mainfront", "-is:split is:front is:primary"
  end

  # Some are not amazing
  it "#name_slug" do
    db.cards.values.to_h{|c| [c.name, c.name_slug] }.should include(
      "_____" => "",
      "\"Ach! Hans, Run!\"" => "Ach-Hans-Run",
      "\"Rumors of My Death . . .\"" => "Rumors-of-My-Death",
      "+2 Mace" => "2-Mace",
      "1996 World Champion" => "1996-World-Champion",
      "Bind (CMB1)" => "Bind-CMB1",
      "Jötun Owl Keeper" => "Jotun-Owl-Keeper",
      "Junún Efreet" => "Junun-Efreet",
      "Look at Me, I'm R&D" => "Look-at-Me-Im-RnD",
      "You're in Command" => "Youre-in-Command",
      "Minsc & Boo, Timeless Heroes" => "Minsc-Boo-Timeless-Heroes",
    )
  end
end

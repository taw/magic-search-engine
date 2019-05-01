describe "Card nicknames" do
  include_context "db"

  # The name is unique
  it "is:shockland" do
    assert_search_results "is:shockland",
      "Blood Crypt",
      "Breeding Pool",
      "Godless Shrine",
      "Hallowed Fountain",
      "Overgrown Tomb",
      "Sacred Foundry",
      "Steam Vents",
      "Stomping Ground",
      "Temple Garden",
      "Watery Grave"
    assert_search_equal "is:shockland", %Q[o:"As ~ enters the battlefield, you may pay 2 life. If you don't, ~ enters the battlefield tapped." or o:"As ~ enters the battlefield, you may pay 2 life. If you don't, it enters the battlefield tapped."]
  end

  # The name is unique-ish
  # There are also Mirage fetchlands, panoramas, Evolving Wilds
  # but at best they're called "bad fetchlands" or some other adjectived form
  it "is:fetchland" do
    assert_search_results "is:fetchland",
      "Arid Mesa",
      "Marsh Flats",
      "Misty Rainforest",
      "Scalding Tarn",
      "Verdant Catacombs",
      "Bloodstained Mire",
      "Flooded Strand",
      "Polluted Delta",
      "Windswept Heath",
      "Wooded Foothills"
    assert_search_results "is:fetchland",
      *cards_matching{|c|
        c.text =~ %r[\{T\}, Pay 1 life, Sacrifice #{c.name}: Search your library for an? \S+ or \S+ card, put it onto the battlefield, then shuffle your library.] }
                  # %r[\{T\}, Pay 1 life, Sacrifice #{c.name}: Search your library for an? \S+ or \S+ card, put it onto the battlefield, then shuffle your library.
  end

  # The name is also used for all lands that produce 2 mana colors
  it "is:dual" do
    assert_search_results "is:dual",
      "Badlands",
      "Bayou",
      "Plateau",
      "Savannah",
      "Scrubland",
      "Taiga",
      "Tropical Island",
      "Tundra",
      "Underground Sea",
      "Volcanic Island"
      assert_search_results "is:dual",
        *cards_matching{|c|
          c.types.include?("land") &&
          !c.types.include?("basic") &&
          c.types.size == 3 &&
          c.text == "" }
  end

  # The name is unique
  it "is:bounceland" do
    assert_search_results "is:bounceland",
      "Azorius Chancery",
      "Boros Garrison",
      "Dimir Aqueduct",
      "Golgari Rot Farm",
      "Gruul Turf",
      "Izzet Boilerworks",
      "Orzhov Basilica",
      "Rakdos Carnarium",
      "Selesnya Sanctuary",
      "Simic Growth Chamber"
      assert_search_results "is:bounceland",
        *cards_matching{|c|
          c.text =~ %r[#{c.name} enters the battlefield tapped.\nWhen #{c.name} enters the battlefield, return a land you control to its owner's hand.\n\{T\}: Add \{.\}\{.\}]}
  end

  # The name is unique
  it "is:fastland" do
    assert_search_results "is:fastland",
      "Blackcleave Cliffs",
      "Blooming Marsh",
      "Botanical Sanctum",
      "Concealed Courtyard",
      "Copperline Gorge",
      "Darkslick Shores",
      "Inspiring Vantage",
      "Razorverge Thicket",
      "Seachrome Coast",
      "Spirebluff Canal"
      assert_search_results "is:fastland",
        *cards_matching{|c|
          c.text =~ %r[#{c.name} enters the battlefield tapped unless you control two or fewer other lands.\n\{T\}: Add \{.\} or \{.\}.]
        }
  end

  # The name is unique
  # Some cards are duplicated
  # There are some other lands that give you land when they etb
  # like Radiant Fountain or Glimmerpost
  # but nobody calls them gainlands
  it "is:gainland" do
    assert_search_results "is:gainland",
      "Akoum Refuge",
      "Bloodfell Caves",
      "Blossoming Sands",
      "Dismal Backwater",
      "Graypelt Refuge",
      "Jungle Hollow",
      "Jwar Isle Refuge",
      "Kazandu Refuge",
      "Rugged Highlands",
      "Scoured Barrens",
      "Sejiri Refuge",
      "Swiftwater Cliffs",
      "Thornwood Falls",
      "Tranquil Cove",
      "Wind-Scarred Crag"
    assert_search_results "is:gainland",
      *cards_matching{|c|
        c.text =~ %r[#{c.name} enters the battlefield tapped.\nWhen #{c.name} enters the battlefield, you gain 1 life.\n\{T\}: Add \{.\} or \{.\}.]}
  end

  # The name is unique
  it "is:checkland" do
    assert_search_results "is:checkland",
      "Clifftop Retreat",
      "Dragonskull Summit",
      "Drowned Catacomb",
      "Glacial Fortress",
      "Hinterland Harbor",
      "Isolated Chapel",
      "Rootbound Crag",
      "Sulfur Falls",
      "Sunpetal Grove",
      "Woodland Cemetery"
    assert_search_results "is:checkland",
      *cards_matching{|c|
        c.text =~ %r[#{c.name} enters the battlefield tapped unless you control an? \S+ or an? \S+.\n\{T\}: Add \{.\} or \{.\}.]}
  end

  # This is a bit dubious
  # It could mean 10 Shadowmoor/Eventide filter lands
  # or those plus 5 Odyssey filter lands
  # or those plus a few unique lands (scryfall includes Crystal Quarry)
  it "is:filterland" do
    assert_search_results "is:filterland",
      "Skycloud Expanse",
      "Darkwater Catacombs",
      "Shadowblood Ridge",
      "Mossfire Valley",
      "Sungrass Prairie",
      "Mystic Gate",
      "Sunken Ruins",
      "Graven Cairns",
      "Fire-Lit Thicket",
      "Wooded Bastion",
      "Fetid Heath",
      "Cascade Bluffs",
      "Twilight Mire",
      "Rugged Prairie",
      "Flooded Grove"
    assert_search_results "is:filterland",
      *cards_matching{|c|
        c.types.include?("land") &&
        c.text =~ %r[\{\S+\}, \{T\}: Add \{.\}\{.\}(,| |\.)]
      }
  end

  # The name is unique
  it "is:manland" do
    assert_search_results "is:manland",
      "Blinkmoth Nexus",
      "Celestial Colonnade",
      "Creeping Tar Pit",
      "Dread Statuary",
      "Faerie Conclave",
      "Forbidding Watchtower",
      "Ghitu Encampment",
      "Hissing Quagmire",
      "Hostile Desert",
      "Inkmoth Nexus",
      "Lavaclaw Reaches",
      "Lumbering Falls",
      "Mishra's Factory",
      "Mobilized District",
      "Mutavault",
      "Nantuko Monastery",
      "Needle Spires",
      "Raging Ravine",
      "Shambling Vent",
      "Sorrow's Path",
      "Spawning Pool",
      "Stalking Stones",
      "Stirring Wildwood",
      "Svogthos, the Restless Tomb",
      "Treetop Village",
      "Wandering Fumarole"
    assert_search_equal "is:manland", "t:land o:becomes o:creature"
  end

  # There are other lands with scry (New Benalia, Soldevi Excavations),
  # but this name is used only for these
  it "is:scryland" do
    assert_search_results "is:scryland",
      "Temple of Abandon",
      "Temple of Deceit",
      "Temple of Enlightenment",
      "Temple of Epiphany",
      "Temple of Malady",
      "Temple of Malice",
      "Temple of Mystery",
      "Temple of Plenty",
      "Temple of Silence",
      "Temple of Triumph"
    assert_search_equal "is:scryland",
      'o:"~ enters the battlefield tapped." o:"When ~ enters the battlefield, scry 1." o:"} or {"'
  end

  # The name is unique
  it "is:battleland" do
    assert_search_results "is:battleland",
      "Prairie Stream",
      "Sunken Hollow",
      "Smoldering Marsh",
      "Cinder Glade",
      "Canopy Vista"
    assert_search_equal "is:battleland",
      'o:"~ enters the battlefield tapped unless you control two or more basic lands."'
  end

  # There are other Gates (only one as of GRN), Guildgate specifically refers to the original double-cycle
  it "is:guildgate" do
    assert_search_results "is:guildgate",
      "Azorius Guildgate",
      "Dimir Guildgate",
      "Rakdos Guildgate",
      "Gruul Guildgate",
      "Selesnya Guildgate",
      "Orzhov Guildgate",
      "Izzet Guildgate",
      "Golgari Guildgate",
      "Boros Guildgate",
      "Simic Guildgate"
    assert_search_equal "is:guildgate",
      't:Gate ci=2'
  end

  # A card that lists a lot of keywords in a single list, in an order that's different from the canonical keyword order
  # This definition is more strict than some people use the term “keyword soup”, but it is useful for figuring out relative order of keywords by filtering these cards out
  it "is:keywordsoup" do
    assert_search_results "is:keywordsoup",
      "Animus of Predation",
      "Cairn Wanderer",
      "Concerted Effort",
      "Death-Mask Duplicant",
      "Greater Morphling",
      "Majestic Myriarch",
      "Odric, Lunarch Marshal",
      "Soulflayer"
    assert_search_results "is:keywordsoup",
      *cards_matching{|c|
        c.name != "Urza, Academy Headmaster" and
        ["deathtouch", "defender", "double strike", "enchant", "equip", "first strike", "flash", "flying", "haste", "hexproof", "indestructible", "intimidate", "landwalk", "lifelink", "protection", "reach", "shroud", "trample", "vigilance"].count {
          |keyword| c.text.downcase.include? keyword
        } > 6
      }
  end
end

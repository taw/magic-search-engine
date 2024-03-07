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
    assert_search_equal "is:shockland", %[o:"As ~ enters the battlefield, you may pay 2 life. If you don't, it enters the battlefield tapped."]
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
        c.text =~ %r[\{T\}, Pay 1 life, Sacrifice #{Regexp.escape c.name}: Search your library for an? \S+ or \S+ card, put it onto the battlefield, then shuffle.] }
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
      "Coral Atoll",
      "Dimir Aqueduct",
      "Dormant Volcano",
      "Everglades",
      "Golgari Rot Farm",
      "Gruul Turf",
      "Guildless Commons",
      "Izzet Boilerworks",
      "Jungle Basin",
      "Karoo",
      "Orzhov Basilica",
      "Rakdos Carnarium",
      "Selesnya Sanctuary",
      "Simic Growth Chamber"
    assert_search_results "is:bounceland",
      *cards_matching{|c|
        c.text =~ %r[#{Regexp.escape c.name} enters the battlefield tapped.\nWhen #{Regexp.escape c.name} enters the battlefield, return a land you control to its owner's hand.\n\{T\}: Add \{.\}\{.\}] or
        c.text =~ %r[#{Regexp.escape c.name} enters the battlefield tapped.\nWhen #{Regexp.escape c.name} enters the battlefield, sacrifice it unless you return an? untapped \S+ you control to its owner's hand.\n\{T\}: Add \{.\}\{.\}]
      }
    assert_search_equal "is:bounceland", "is:karoo"
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
        c.text =~ %r[#{Regexp.escape c.name} enters the battlefield tapped unless you control two or fewer other lands.\n\{T\}: Add \{.\} or \{.\}.]
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
        c.text =~ %r[#{Regexp.escape c.name} enters the battlefield tapped.\nWhen #{Regexp.escape c.name} enters the battlefield, you gain 1 life.\n\{T\}: Add \{.\} or \{.\}.]}
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
        c.text =~ %r[#{Regexp.escape c.name} enters the battlefield tapped unless you control an? \S+ or an? \S+.\n\{T\}: Add \{.\} or \{.\}.]}
  end

  # This is a bit dubious
  # It could mean 10 Shadowmoor/Eventide filter lands
  # or those plus 5 Odyssey filter lands
  # or those plus a few unique lands (scryfall includes Crystal Quarry)
  it "is:filterland" do
    assert_search_results "is:filterland",
      "Cascade Bluffs",
      "Cascading Cataracts",
      "Crystal Quarry",
      "Darkwater Catacombs",
      "Desolate Mire",
      "Ferrous Lake",
      "Fetid Heath",
      "Fire-Lit Thicket",
      "Flooded Grove",
      "Graven Cairns",
      "Mossfire Valley",
      "Mystic Gate",
      "Overflowing Basin",
      "Rugged Prairie",
      "Shadowblood Ridge",
      "Skycloud Expanse",
      "Sungrass Prairie",
      "Sunken Ruins",
      "Sunscorched Divide",
      "Twilight Mire",
      "Viridescent Bog",
      "Wooded Bastion"
    assert_search_results "is:filterland",
      *cards_matching{|c|
        c.types.include?("land") && (
          c.text =~ %r[\{\S+\}, \{T\}: Add \{.\}\{.\}(,| |\.)] or
          c.text.include?("{5}, {T}: Add")
        )
      }
  end

  # The name is unique
  it "is:manland" do
    assert_search_results "is:manland",
      "Blinkmoth Nexus",
      "Cave of the Frost Dragon",
      "Cavernous Maw",
      "Celestial Colonnade",
      "Creeping Tar Pit",
      "Den of the Bugbear",
      "Domesticated Watercourse",
      "Dread Statuary",
      "Faceless Haven",
      "Faerie Conclave",
      "Forbidding Watchtower",
      "Frostwalk Bastion",
      "Ghitu Encampment",
      "Hall of Storm Giants",
      "Hissing Quagmire",
      "Hive of the Eye Tyrant",
      "Hostile Desert",
      "Inkmoth Nexus",
      "Lair of the Hydra",
      "Lavaclaw Reaches",
      "Lumbering Falls",
      "Mishra's Factory",
      "Mishra's Foundry",
      "Mobilized District",
      "Mutavault",
      "Nantuko Monastery",
      "Needle Spires",
      "Raging Ravine",
      "Restless Anchorage",
      "Restless Bivouac",
      "Restless Cottage",
      "Restless Fortress",
      "Restless Prairie",
      "Restless Reef",
      "Restless Ridgeline",
      "Restless Spire",
      "Restless Vents",
      "Restless Vinestalk",
      "Shambling Vent",
      "Spawning Pool",
      "Stalking Stones",
      "Stirring Wildwood",
      "Svogthos, the Restless Tomb",
      "Treetop Village",
      "Wandering Fumarole"
    assert_search_equal "is:manland", "t:land o:becomes o:creature -(Tyrite Sanctum) -(Sorrow's Path) -(Mech Hangar)"
    assert_search_equal "is:manland", "is:creatureland"
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
    assert_search_equal "is:battleland", "is:tangoland"
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
      "t:Gate ci=2"
  end

  it "is:painland" do
    assert_search_results "is:painland",
      "Adarkar Wastes",
      "Battlefield Forge",
      "Brushland",
      "Caves of Koilos",
      "Karplusan Forest",
      "Llanowar Wastes",
      "Shivan Reef",
      "Sulfurous Springs",
      "Underground River",
      "Yavimaya Coast"
    assert_search_equal "is:painland",
      't:land -o:tapped o:/\{T\}: Add \{.\} or \{.\}. (.*?) deals 1 damage to you./'
  end

  it "is:triland" do
    assert_search_results "is:triland",
      "Arcane Sanctum",
      "Crumbling Necropolis",
      "Frontier Bivouac",
      "Jungle Shrine",
      "Mystic Monastery",
      "Nomad Outpost",
      "Opulent Palace",
      "Sandsteppe Citadel",
      "Savage Lands",
      "Seaside Citadel"
    assert_search_equal "is:triland",
      't:land o:/\{T\}: Add \{.\}, \{.\}, or \{.\}/ -o:sacrifice o:tapped -o:cycling'
  end

  it "is:triome" do
    assert_search_results "is:triome",
      "Indatha Triome",
      "Jetmir's Garden",
      "Ketria Triome",
      "Raffine's Tower",
      "Raugrin Triome",
      "Savai Triome",
      "Spara's Headquarters",
      "Xander's Lounge",
      "Zagoth Triome",
      "Ziatora's Proving Ground"
    assert_search_equal "is:triome",
      't:land o:tapped o:"cycling {3}"'
    assert_search_equal "is:tricycleland", "is:triome"
  end

  it "is:canopyland" do
    assert_search_results "is:canopyland",
      "Fiery Islet",
      "Horizon Canopy",
      "Nurturing Peatland",
      "Silent Clearing",
      "Sunbaked Canyon",
      "Waterlogged Grove"
    assert_search_equal "is:canopyland",
      't:land o:"pay 1 life" o:"{1}, {T}, Sacrifice ~: Draw a card."'
    assert_search_equal "is:canland", "is:canopyland"
  end

  it "is:shadowland" do
    assert_search_results "is:shadowland",
      "Choked Estuary",
      "Foreboding Ruins",
      "Fortified Village",
      "Frostboil Snarl",
      "Furycalm Snarl",
      "Game Trail",
      "Necroblossom Snarl",
      "Port Town",
      "Shineshadow Snarl",
      "Vineglimmer Snarl"
    assert_search_equal "is:shadowland",
      %q[t:land o:/As (.*) enters the battlefield, you may reveal an? \S+ or \S+/ o:"If you don't, ~ enters the battlefield tapped"]
  end

  # This is quite questionable
  it "is:storageland" do
    assert_search_results "is:storageland",
      "Calciform Pools",
      "Crucible of the Spirit Dragon",
      "Dreadship Reef",
      "Fountain of Cho",
      "Fungal Reaches",
      "Mage-Ring Network",
      "Mercadian Bazaar",
      "Molten Slagheap",
      "Rushwood Grove",
      "Saltcrusted Steppe",
      "Saprazzan Cove",
      "Subterranean Hangar"
    assert_search_equal "is:storageland",
      't:land o:"Remove" o:"storage counters from" -o:"you may"'
  end

  # A card that lists a lot of keywords in a single list, in an order that's different from the canonical keyword order
  # This definition is more strict than some people use the term “keyword soup”, but it is useful for figuring out relative order of keywords by filtering these cards out
  it "is:keywordsoup" do
    assert_search_results "is:keywordsoup",
      "Akroma, Vision of Ixidor",
      "Animus of Predation",
      "Cairn Wanderer",
      "Concerted Effort",
      "Crystalline Giant",
      "D00-DL, Caricaturist",
      "Death-Mask Duplicant",
      "Eater of Virtue",
      "Greater Morphling",
      "Indominus Rex, Alpha",
      "Kathril, Aspect Warper",
      "Majestic Myriarch",
      "Odric, Blood-Cursed",
      "Odric, Lunarch Marshal",
      "Priest of Possibility",
      "Rayami, First of the Fallen",
      "Selective Adaptation",
      "Soulflayer",
      "Sproutwatch Dryad",
      "Thunderous Orator",
      "Urborg Scavengers",
      "Wretched Bonemass"
    assert_search_results "is:keywordsoup",
      *cards_matching{|c|
        c.name != "Urza, Academy Headmaster" and
        ["deathtouch", "defender", "double strike", "enchant", "equip", "first strike", "flash", "flying", "haste", "hexproof", "indestructible", "intimidate", "landwalk", "lifelink", "protection", "reach", "shroud", "trample", "vigilance"].count {
          |keyword| c.text.downcase.include? keyword
        } > 6
      }
  end

  it "is:ante" do
    assert_search_results "is:ante",
      "Amulet of Quoz",
      "Bronze Tablet",
      "Contract from Below",
      "Darkpact",
      "Demonic Attorney",
      "Jeweled Bird",
      "Rebirth",
      "Tempest Efreet",
      "Timmerian Fiends"

    assert_search_equal "is:ante", 'o:/\bante\b/'
  end

  it "is:racist" do
    assert_search_results "is:racist",
      "Cleanse",
      "Crusade",
      "Imprison",
      "Invoke Prejudice",
      "Jihad",
      "Pradesh Gypsies",
      "Stone-Throwing Devils"
  end

  it "is:masterpiece" do
    assert_search_equal "is:masterpiece", "st:masterpiece"
  end

  it "is:cycleland" do
    assert_search_results "is:cycleland",
      "Canyon Slough",
      "Fetid Pools",
      "Irrigated Farmland",
      "Scattered Groves",
      "Sheltered Thicket"

    assert_search_equal "is:cycleland", 't:land o:"cycling {2}" (t:plains or t:island or t:swamp or t:mountain or t:forest)'
    assert_search_equal "is:cycleland", "is:bicycleland"
    assert_search_equal "is:cycleland", "is:bikeland"
  end
end

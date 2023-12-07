describe "Spelling" do
  include_context "db"

  it do
    assert_search_results "related:cmc=9",
      "Golgothian Sylex",      # Colossus of Sardia
      "Scalespeaker Shepherd", # Alchemy version
      "Sift Through Sands",    # The Unspeakable
      "Urborg Panther"         # Spirit of the Night
  end

  it "Battleborn partner" do
    assert_search_results "related:Zndrsplt",
      "Okaun, Eye of Chaos"
  end

  it "Domesticated Mammoth" do
    assert_search_results "related:Pacifism",
      "Domesticated Mammoth"
  end

  it "Alchemy" do
    # This test somehow also covers dungeons
    assert_search_results "related:Acererak",
      "Acererak the Archlich",
      "Acererak the Archlich (Alchemy)",
      "Dungeon of the Mad Mage",
      "Lost Mine of Phandelver",
      "Tomb of Annihilation"
  end

  it "specialize" do
    assert_search_results "related:Alora",
      "Alora, Cheerful Assassin",
      "Alora, Cheerful Mastermind",
      "Alora, Cheerful Scout",
      "Alora, Cheerful Swashbuckler",
      "Alora, Cheerful Thief",
      "Alora, Rogue Companion"
  end

  # HBG examples, but there's a lot more spellbooks out there
  it "spellbooks" do
    assert_search_results %Q[related:"Follow the Tracks"],
      "Gate to the Citadel",
      "Gate to Seatower",
      "Gate of the Black Dragon",
      "Gate to Tumbledown",
      "Gate to Manorborn"

    assert_search_results %Q[related:"The Hourglass Coven"],
      "Hag of Syphoned Breath",
      "Hag of Dark Duress",
      "Hag of Ceaseless Torment",
      "Hag of Inner Weakness",
      "Hag of Death's Legion",
      "Hag of Scoured Thoughts",
      "Hag of Twisted Visions",
      "Hag of Mage's Doom",
      "Hag of Noxious Nightmares"

    assert_search_results %Q[related:"Oyaminartok, Polar Werebear"],
      "Mystic Skyfish",
      "Moat Piranhas",
      "Riptide Turtle",
      "Spined Megalodon",
      "Ruin Crab",
      "Stinging Lionfish",
      "Archipelagore",
      "Pouncing Shoreshark",
      "Junk Winder",
      "Sigiled Starfish",
      "Sea-Dasher Octopus",
      "Voracious Greatshark",
      "Nadir Kraken",
      "Nezahal, Primal Tide",
      "Pursued Whale"
  end

  it "is:spellbook" do
    assert_search_include "is:spellbook",
      "Black Lotus"
  end

  it "has:spellbook" do
    assert_search_include "has:spellbook",
      "Oyaminartok, Polar Werebear"
  end

  it "is:specialized" do
    assert_search_results "is:specialized Alora",
      "Alora, Cheerful Assassin",
      "Alora, Cheerful Mastermind",
      "Alora, Cheerful Scout",
      "Alora, Cheerful Swashbuckler",
      "Alora, Cheerful Thief"
  end

  it "has:specialized" do
    assert_search_results "has:specialized Alora",
      "Alora, Rogue Companion"
  end

  it "*" do
    assert_search_equal "related:t:*", "related:*"
  end

  # Should it be a different operator?
  it "Planar Chaos" do
    assert_search_results %Q[related:"Malach of the Dawn"], "Ghost Ship"
    assert_search_results %Q[related:"Ghost Ship"], "Malach of the Dawn"
  end

  it "Garth One-Eye" do
    assert_search_results %Q[related:"Black Lotus"], "Garth One-Eye", "Oracle of the Alpha"
    assert_search_results "related:Garth",
      "Disenchant",
      "Braingeyser",
      "Terror",
      "Shivan Dragon",
      "Regrowth",
      "Black Lotus"
  end

  # As defined by CR
  # But don't list card as its own relation
  it "Apocalypse Chime" do
    assert_search_results %Q[related:"Aysen Crusader"], "Apocalypse Chime"
    assert_search_results %Q[related:"Apocalypse Chime"],
      "Abbey Gargoyles",
      "Abbey Matron",
      "Aether Storm",
      "Aliban's Tower",
      "Ambush",
      "Ambush Party",
      "Anaba Ancestor",
      "Anaba Bodyguard",
      "Anaba Shaman",
      "Anaba Spirit Crafter",
      "An-Havva Constable",
      "An-Havva Inn",
      "An-Havva Township",
      "An-Zerrin Ruins",
      "Autumn Willow",
      "Aysen Abbey",
      "Aysen Bureaucrats",
      "Aysen Crusader",
      "Aysen Highway",
      "Baki's Curse",
      "Baron Sengir",
      "Beast Walkers",
      "Black Carriage",
      "Broken Visage",
      "Carapace",
      "Castle Sengir",
      "Cemetery Gate",
      "Chain Stasis",
      "Chandler",
      "Clockwork Gnomes",
      "Clockwork Steed",
      "Clockwork Swarm",
      "Coral Reef",
      "Dark Maze",
      "Daughter of Autumn",
      "Death Speakers",
      "Didgeridoo",
      "Drudge Spell",
      "Dry Spell",
      "Dwarven Pony",
      "Dwarven Sea Clan",
      "Dwarven Trader",
      "Ebony Rhino",
      "Eron the Relentless",
      "Evaporate",
      "Faerie Noble",
      "Feast of the Unicorn",
      "Feroz's Ban",
      "Folk of An-Havva",
      "Forget",
      "Funeral March",
      "Ghost Hounds",
      "Giant Albatross",
      "Giant Oyster",
      "Grandmother Sengir",
      "Greater Werewolf",
      "Hazduhr the Abbot",
      "Headstone",
      "Heart Wolf",
      "Hungry Mist",
      "Ihsan's Shade",
      "Irini Sengir",
      "Ironclaw Curse",
      "Jinx",
      "Joven",
      "Joven's Ferrets",
      "Joven's Tools",
      "Koskun Falls",
      "Koskun Keep",
      "Labyrinth Minotaur",
      "Leaping Lizard",
      "Leeches",
      "Mammoth Harness",
      "Marjhan",
      "Memory Lapse",
      "Merchant Scroll",
      "Mesa Falcon",
      "Mystic Decree",
      "Narwhal",
      "Orcish Mine",
      "Primal Order",
      "Prophecy",
      "Rashka the Slayer",
      "Reef Pirates",
      "Renewal",
      "Retribution",
      "Reveka, Wizard Savant",
      "Root Spider",
      "Roots",
      "Roterothopter",
      "Rysorian Badger",
      "Samite Alchemist",
      "Sea Sprite",
      "Sea Troll",
      "Sengir Autocrat",
      "Sengir Bats",
      "Serra Aviary",
      "Serra Bestiary",
      "Serra Inquisitors",
      "Serra Paladin",
      "Serrated Arrows",
      "Shrink",
      "Soraya the Falconer",
      "Spectral Bears",
      "Timmerian Fiends",
      "Torture",
      "Trade Caravan",
      "Truce",
      "Veldrane of Sengir",
      "Wall of Kelp",
      "Willow Faerie",
      "Willow Priestess",
      "Winter Sky",
      "Wizards' School"
  end

  it "City in a Bottle" do
    assert_search_results %Q[related:Cyclone], "City in a Bottle"
    assert_search_results %Q[related:"City in a Bottle"],
      "Abu Ja'far",
      "Aladdin",
      "Aladdin's Lamp",
      "Aladdin's Ring",
      "Ali Baba",
      "Ali from Cairo",
      "Army of Allah",
      "Bazaar of Baghdad",
      "Bird Maiden",
      "Bottle of Suleiman",
      "Brass Man",
      "Camel",
      "City of Brass",
      "Cuombajj Witches",
      "Cyclone",
      "Dancing Scimitar",
      "Dandân",
      "Desert",
      "Desert Nomads",
      "Desert Twister",
      "Diamond Valley",
      "Drop of Honey",
      "Ebony Horse",
      "Elephant Graveyard",
      "El-Hajjâj",
      "Erg Raiders",
      "Erhnam Djinn",
      "Eye for an Eye",
      "Fishliver Oil",
      "Flying Carpet",
      "Flying Men",
      "Ghazbán Ogre",
      "Giant Tortoise",
      "Guardian Beast",
      "Hasran Ogress",
      "Hurr Jackal",
      "Ifh-Bíff Efreet",
      "Island Fish Jasconius",
      "Island of Wak-Wak",
      "Jandor's Ring",
      "Jandor's Saddlebags",
      "Jeweled Bird",
      "Jihad",
      "Junún Efreet",
      "Juzám Djinn",
      "Khabál Ghoul",
      "King Suleiman",
      "Kird Ape",
      "Library of Alexandria",
      "Magnetic Mountain",
      "Merchant Ship",
      "Metamorphosis",
      "Mijae Djinn",
      "Moorish Cavalry",
      "Nafs Asp",
      "Oasis",
      "Old Man of the Sea",
      "Oubliette",
      "Piety",
      "Pyramids",
      "Repentant Blacksmith",
      "Ring of Ma'rûf",
      "Rukh Egg",
      "Sandals of Abdallah",
      "Sandstorm",
      "Serendib Djinn",
      "Serendib Efreet",
      "Shahrazad",
      "Sindbad",
      "Singing Tree",
      "Sorceress Queen",
      "Stone-Throwing Devils",
      "Unstable Mutation",
      "War Elephant",
      "Wyluli Wolf",
      "Ydwen Efreet"
  end

  it "Golgothian Sylex" do
    assert_search_results %Q[related:"Battering Ram"], "Golgothian Sylex"
    assert_search_results %Q[related:"Golgothian Sylex"],
      "Amulet of Kroog",
      "Argivian Archaeologist",
      "Argivian Blacksmith",
      "Argothian Pixies",
      "Argothian Treefolk",
      "Armageddon Clock",
      "Artifact Blast",
      "Artifact Possession",
      "Artifact Ward",
      "Ashnod's Altar",
      "Ashnod's Battle Gear",
      "Ashnod's Transmogrant",
      "Atog",
      "Battering Ram",
      "Bronze Tablet",
      "Candelabra of Tawnos",
      "Circle of Protection: Artifacts",
      "Citanul Druid",
      "Clay Statue",
      "Clockwork Avian",
      "Colossus of Sardia",
      "Coral Helm",
      "Crumble",
      "Cursed Rack",
      "Damping Field",
      "Detonate",
      "Drafna's Restoration",
      "Dragon Engine",
      "Dwarven Weaponsmith",
      "Energy Flux",
      "Feldon's Cane",
      "Gaea's Avenger",
      "Gate to Phyrexia",
      "Goblin Artisans",
      "Grapeshot Catapult",
      "Haunting Wind",
      "Hurkyl's Recall",
      "Ivory Tower",
      "Jalum Tome",
      "Martyrs of Korlis",
      "Mightstone",
      "Millstone",
      "Mishra's Factory",
      "Mishra's War Machine",
      "Mishra's Workshop",
      "Obelisk of Undoing",
      "Onulet",
      "Orcish Mechanics",
      "Ornithopter",
      "Phyrexian Gremlins",
      "Power Artifact",
      "Powerleech",
      "Priest of Yawgmoth",
      "Primal Clay",
      "The Rack",
      "Rakalite",
      "Reconstruction",
      "Reverse Polarity",
      "Rocket Launcher",
      "Sage of Lat-Nam",
      "Shapeshifter",
      "Shatterstorm",
      "Staff of Zegon",
      "Strip Mine",
      "Su-Chi",
      "Tablet of Epityr",
      "Tawnos's Coffin",
      "Tawnos's Wand",
      "Tawnos's Weaponry",
      "Tetravus",
      "Titania's Song",
      "Transmute Artifact",
      "Triskelion",
      "Urza's Avenger",
      "Urza's Chalice",
      "Urza's Mine",
      "Urza's Miter",
      "Urza's Power Plant",
      "Urza's Tower",
      "Wall of Spears",
      "Weakstone",
      "Xenic Poltergeist",
      "Yawgmoth Demon",
      "Yotian Soldier"
  end
end

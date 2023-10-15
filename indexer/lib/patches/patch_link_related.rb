# Inclruding Specialized / Spellbooks here is arguably redundant with their special fields

class PatchLinkRelated < Patch
  attr_reader :links

  ExtraRelations = {
    "Garth One-Eye" => [
      "Disenchant",
      "Braingeyser",
      "Terror",
      "Shivan Dragon",
      "Regrowth",
      "Black Lotus",
    ],
    "City in a Bottle" => [
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
      "City in a Bottle",
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
      "Ydwen Efreet",
    ],
    "Golgothian Sylex" => [
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
      "Golgothian Sylex",
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
    ],
    "Apocalypse Chime" => [
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
      "Apocalypse Chime",
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
      "Wizards' School",
    ],
    # Special tokens
    "Undercity" => ["The Initiative"],
    "The Ring" => ["The Ring Tempts You"],
  }

  def add_link(name1, name2)
    return if name1 == name2
    return unless @cards[name1]
    return unless @cards[name2]
    links[name1] << name2
    links[name2] << name1
  end

  def call
    # The index has tokens as cards, CardDatabase filters them out
    # We should probably move them out of the way before that
    all_card_names = @cards.values.flatten.select{|c| c["layout"] != "token"}.map{|c| c["name"]}.uniq
    # Some token names to prevent fake matches
    # like Smoke Spirits' Aid -> Smoke
    all_card_names += ["Smoke Blessing"]

    # Get longest match so
    # "Take Inventory" doesn't mistakenly seem to refer to "Take" etc.
    # Second regexp for empire series
    any_card = Regexp.union(all_card_names.sort_by(&:size).reverse)
    rx = /\b(?:named|Partner with|token copy of) (#{any_card})(?:(?:,|,? and|,? or) (#{any_card}))?(?:(?:,|,? and|,? or) (#{any_card}))?/

    # Extract links
    @links = Hash.new{|ht,k| ht[k] = Set[]}
    each_printing do |printing|
      name = printing["name"]
      matching_cards = (printing["text"]||"").scan(rx).flatten.uniq - [name, nil]
      next if matching_cards.empty?
      matching_cards.each do |other|
        add_link name, other
      end
    end

    ExtraRelations.each do |name, others|
      others.each do |other|
        add_link name, other
      end
    end

    # I'm not loving this, but it's the simpler way
    PatchSpecialize::SpecializeGroups.each do |group|
      group.each do |name1|
        group.each do |name2|
          add_link name1, name2
        end
      end
    end

    each_printing do |printing|
      name = printing["name"]
      next unless name.end_with?(" (Alchemy)")
      base_name = name.sub(" (Alchemy)", "")
      add_link name, base_name
    end

    each_printing do |printing|
      name = printing["name"]
      spellbook = printing["spellbook"]

      if spellbook
        # Temporary debugging as spellbooks in mtgjson have issues
        # puts "Spellbook for: #{name}: #{spellbook.inspect}"
        spellbook.each do |other|
          add_link name, other
        end
      end
    end

    # Special Tokens
    each_printing do |printing|
      name = printing["name"]
      text = printing["text"]

      # The Ring
      if text =~ /ring-bearer|ring tempts you/i
        add_link "The Ring", name
        add_link "The Ring Tempts You", name
      end

      # Initiative
      if text =~ /have the initiative|take the initiative/i
        add_link "The Initiative", name
        add_link "Undercity", name
      end

      # Dungeon
      # This is maybe a bit questionable, "venture" can't do Undercity, but other dungeon abilities work with Undercity too
      if text =~ /venture into the dungeon/i
        add_link "Dungeon of the Mad Mage", name
        add_link "Lost Mine of Phandelver", name
        add_link "Tomb of Annihilation", name
      end

      if text =~ /complete a dungeon|completed a dungeon|dungeons/i
        add_link "Undercity", name
        add_link "Dungeon of the Mad Mage", name
        add_link "Lost Mine of Phandelver", name
        add_link "Tomb of Annihilation", name
      end

      # Acererak (and its Alchemy version) also use "completed Tomb of Annihilation", but they already match the above

      # Monarch - TODO
    end

    # Apply links
    links.each do |name, others|
      @cards[name].each do |printing|
        printing["related"] ||= []
        printing["related"] += others.to_a
        printing["related"] = printing["related"].sort
      end
    end
  end
end

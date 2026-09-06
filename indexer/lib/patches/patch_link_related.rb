# Including Specialized / Spellbooks here is arguably redundant with their special fields

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
    # The regexps can't see these, as the text spells the names differently
    # ("Urza's Power-Plant"), or jokes about them ("Grotag ThrASHer")
    "Urza's Mine" => [
      "Urza's Power Plant",
      "Urza's Tower",
    ],
    "Urza's Power Plant" => [
      "Urza's Tower",
    ],
    "Urza's Fun House" => [
      "Urza's Mine",
      "Urza's Power Plant",
      "Urza's Tower",
    ],
    "Command Mine" => [
      "Command Power Plant",
      "Command Tower",
    ],
    "Command Power Plant" => [
      "Command Tower",
    ],
    "The Ash Lizard" => [
      "Ash Zealot",
      "Bog-Strider Ash",
      "Grotag Thrasher",
      "Seedguide Ash",
      "Unstoppable Ash",
      "Viashino Warrior",
    ],
    # Cards which refer to another card without ever naming it in a way
    # any of the patterns below could pick up
    "The Keeper of Kaldra" => [
      "Helm of Kaldra",
      "Shield of Kaldra",
      "Sword of Kaldra",
    ],
    "Ensoul Ring" => ["Sol Ring"],
    "Incubob" => ["Dark Confidant"],
    "Questing Cosplayer" => ["Questing Beast"],

    # Special tokens
    "Undercity" => ["The Initiative"],
    "The Ring" => ["The Ring Tempts You"],
  }

  # Basic land names in rules text are nearly always land types
  # ("choose Island or Swamp"), not references to the cards
  BasicLandNames = ["Plains", "Island", "Swamp", "Mountain", "Forest", "Wastes"]

  def add_link(name1, name2)
    return if name1 == name2
    return unless @cards[name1]
    return unless @cards[name2]
    links[name1] << name2
    links[name2] << name1
  end

  # "create a Blood token" or "create a Treasure token" refer to token types,
  # not to the cards Blood or Treasure Hunter
  def token_subtypes
    result = Set[]
    each_printing do |printing|
      result.merge(printing["subtypes"] || [])
    end
    each_set do |set|
      (set["tokens"] || []).each do |token|
        result.merge(token["subtypes"] || [])
      end
    end
    result
  end

  def card_names_matched_by_text
    # The index has tokens as cards, CardDatabase filters them out
    # We should probably move them out of the way before that
    names = @cards.values.flatten.select{|c| c["layout"] != "token"}.map{|c| c["name"]}.uniq
    # Some token names to prevent fake matches
    # like Smoke Spirits' Aid -> Smoke
    names += ["Smoke Blessing"]
    # "X" is a real card, but it only ever matches things like
    # "create X tokens", never an actual reference to it
    names.reject{|name| name.size == 1}
  end

  # All the ways one card's text can point at another card's name.
  # It's just regexps, so it's neither complete nor completely accurate.
  def text_patterns(all_card_names)
    # Get longest match first, so
    # "Take Inventory" doesn't mistakenly seem to refer to "Take" etc.
    any_card = Regexp.union(all_card_names.sort_by(&:size).reverse)
    # And don't match just the beginning of a longer name,
    # like "Scar" in "cards exiled with Scarlet Witch"
    card = /#{any_card}(?![\w'’])/
    # "A, B, and C", "A; B; C", "A or B"
    separator = /(?:,\s*|;\s*)(?:and\s+|or\s+)?|\s+(?:and|or)\s+/
    card_list = /#{card}(?:(?:#{separator})#{card})*/
    # "from among the previous playtest cards A, B, or C"
    filler = /(?:the\s+)?(?:[a-z]+\s+){0,3}/

    # Phrases which introduce a list of card names
    prefixes = Regexp.union(
      /\bnamed /,
      /\bPartner with /,
      /\btoken cop(?:y|ies) of /,
      /\bcop(?:y|ies) (?:respectively )?of (?:the card )?/,
      /\bfrom among #{filler}/,
      /\bat random among #{filler}/,
      /\bone of the following[a-z ]*[:—] */,
      /\bone of /,
    )
    # These are too vague to trust with a single name
    # ("Discard a card at random: Regenerate target creature"),
    # so we only take them when an actual list follows
    weak_prefixes = Regexp.union(
      /\b(?:chosen )?at random[:—] */,
      /\b[Cc]hoose (?=[A-Z])/,
    )

    {
      list: /(?:#{prefixes})(#{card_list})/,
      weak_list: /(?:#{weak_prefixes})(#{card}(?:(?:#{separator})#{card})+)/,
      # Matching every card name is expensive, so we look for the phrases first
      # These need to match at least everything the two prefix lists match
      list_hint: /\bnamed |\bPartner with |\bcop(?:y|ies) |\bfrom among |\bone of /,
      weak_list_hint: /at random[:—]|\b[Cc]hoose [A-Z]/,
      # "create a Black Lotus token", as opposed to
      # "create a 1/1 white Soldier creature token"
      token: /\b(?:[Cc]reates?|and)\s+(?:(?:[a-z]+|\d+(?:\/\d+)?|X)\s+){0,3}(#{card})\s+tokens?\b/,
      # Cards which simply list other cards, like Who's That Praetor?
      bullet: /^• (#{card})(?= \(|$)/,
      card: card,
    }
  end

  def cards_mentioned_in_text(text, rx, subtypes)
    result = Set[]
    if text =~ rx[:list_hint]
      text.scan(rx[:list]) do |match|
        result.merge match[0].scan(rx[:card])
      end
    end
    if text =~ rx[:weak_list_hint]
      text.scan(rx[:weak_list]) do |match|
        result.merge match[0].scan(rx[:card]) - BasicLandNames
      end
    end
    if text.include?("token")
      text.scan(rx[:token]) do |match|
        result << match[0] unless subtypes.include?(match[0])
      end
    end
    if text.include?("•")
      text.scan(rx[:bullet]) do |match|
        result << match[0]
      end
    end
    result
  end

  def call
    rx = text_patterns(card_names_matched_by_text)
    subtypes = token_subtypes

    # Extract links
    @links = Hash.new{|ht,k| ht[k] = Set[]}
    seen = Set[]
    each_printing do |printing|
      name = printing["name"]
      text = printing["text"] || ""
      # Same text on every printing of most cards, and this is not cheap
      next unless seen.add?([name, text])
      cards_mentioned_in_text(text, rx, subtypes).each do |other|
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

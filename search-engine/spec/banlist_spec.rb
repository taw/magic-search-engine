describe "Banlist" do
  include_context "db"
  # Based on:
  # http://mtgsalvation.gamepedia.com/Timeline_of_DCI_bans_and_restrictions#2015

  it "banlist_2019" do
    assert_banlist_changes "November 2019",
      "standard banned", "Oko, Thief of Crowns",
      "standard banned", "Once Upon a Time",
      "standard banned", "Veil of Summer",
      "legacy banned", "Wrenn and Six",
      "vintage restricted", "Narset, Parter of Veils"

    assert_banlist_changes "October 2019",
      "standard banned", "Field of the Dead",
      "pauper banned", "Arcum's Astrolabe"

    assert_banlist_changes "August 2019",
      "standard unbanned", "Rampaging Ferocidon",
      "modern banned", "Hogaak, Arisen Necropolis",
      "modern banned", "Faithless Looting",
      "modern unbanned", "Stoneforge Mystic",
      "vintage restricted", "Karn, the Great Creator",
      "vintage restricted", "Mystic Forge",
      "vintage restricted", "Mental Misstep",
      "vintage restricted", "Golgari Grave-Troll",
      "vintage unrestricted", "Fastbond"

    assert_banlist_changes "July 2019",
      "modern banned", "Bridge from Below",
      "pauper banned", "Hymn to Tourach",
      "pauper banned", "Sinkhole",
      "pauper banned", "High Tide"

    assert_banlist_changes "May 2019",
      "pauper banned", "Gush",
      "pauper banned", "Gitaxian Probe",
      "pauper banned", "Daze"

    assert_banlist_changes "January 2019",
      "modern banned", "Krark-Clan Ironworks"
  end

  it "banlist_2018" do
    # These were separate announcements
    assert_banlist_changes "July 2018",
      "legacy banned", "Deathrite Shaman",
      "legacy banned", "Gitaxian Probe",
      "mtgo commander unbanned", "Ancient Tomb",
      "mtgo commander unbanned", "Brainstorm",
      "mtgo commander unbanned", "Chrome Mox",
      "mtgo commander unbanned", "Demonic Tutor",
      "mtgo commander unbanned", "Dig Through Time",
      "mtgo commander unbanned", "Enlightened Tutor",
      "mtgo commander unbanned", "Entomb",
      "mtgo commander unbanned", "Gaea's Cradle",
      "mtgo commander unbanned", "Imperial Seal",
      "mtgo commander unbanned", "Mana Crypt",
      "mtgo commander unbanned", "Mana Drain",
      "mtgo commander unbanned", "Mana Vault",
      "mtgo commander unbanned", "Mox Diamond",
      "mtgo commander unbanned", "Mystical Tutor",
      "mtgo commander unbanned", "Necropotence",
      "mtgo commander unbanned", "Ponder",
      "mtgo commander unbanned", "Preordain",
      "mtgo commander unbanned", "Sol Ring",
      "mtgo commander unbanned", "Sylvan Tutor",
      "mtgo commander unbanned", "Treachery",
      "mtgo commander unbanned", "Treasure Cruise",
      "mtgo commander unbanned", "Vampiric Tutor",
      "mtgo commander unbanned", "Vial Smasher the Fierce",
      "mtgo commander unbanned", "Worldly Tutor",
      "mtgo commander unbanned", "Yawgmoth's Bargain"

    assert_banlist_changes "April 2018",
      "mtgo commander banned", "Edgar Markov",
      "mtgo commander banned", "Chrome Mox",
      "mtgo commander banned", "Ancient Tomb",
      "mtgo commander banned", "Mox Diamond",
      "mtgo commander banned", "Winter Orb",
      "mtgo commander banned", "Sylvan Library",
      "mtgo commander banned", "Worldly Tutor",
      "mtgo commander banned", "Sylvan Tutor",
      "mtgo commander unbanned", "Protean Hulk",
      "mtgo commander unbanned", "Mishra's Workshop",
      "mtgo commander unbanned", "Bazaar of Baghdad",
      "mtgo commander unbanned", "Griselbrand"

    assert_banlist_changes "January 2018",
      "standard banned", "Attune with Aether",
      "standard banned", "Rogue Refiner",
      "standard banned", "Rampaging Ferocidon",
      "standard banned", "Ramunap Ruins"

    assert_banlist_changes "February 2018",
      "modern unbanned", "Jace, the Mind Sculptor",
      "modern unbanned", "Bloodbraid Elf"
  end

  it "banlist_2017" do
    assert_banlist_changes "November 2017",
      "duel commander banned", "Fastbond"

    assert_banlist_changes "October 2017",
      "mtgo commander banned", "Baral, Chief of Compliance",
      "mtgo commander banned", "Demonic Tutor",
      "mtgo commander banned", "Emrakul, the Aeons Torn",
      "mtgo commander banned", "Enlightened Tutor",
      "mtgo commander banned", "Imperial Seal",
      "mtgo commander banned", "Mystical Tutor",
      "mtgo commander banned", "Vampiric Tutor",
      "mtgo commander unbanned", "Arcum Dagsson",
      "mtgo commander unbanned", "Yisan, the Wanderer Bard"

    assert_banlist_changes "September 2017",
      "duel commander restricted", "Edgar Markov",
      "duel commander banned", "Fireblast",
      "duel commander banned", "Eidolon of the Great Revel",
      "duel commander banned", "Sulfuric Vortex",
      "duel commander banned", "Price of Progress"

    assert_banlist_changes "August 2017", # Sep 1 actually
      "vintage restricted", "Thorn of Amethyst",
      "vintage restricted", "Monastery Mentor",
      "vintage unrestricted", "Yawgmoth's Bargain"

    assert_banlist_changes "July 2017",
      "mtgo commander banned", "Vial Smasher the Fierce",
      "mtgo commander banned", "Ponder",
      "mtgo commander banned", "Preordain",
      "mtgo commander banned", "Brainstorm",
      "mtgo commander banned", "Treachery",
      "mtgo commander unbanned", "Biorhythm",
      "mtgo commander unbanned", "Limited Resources",
      "mtgo commander unbanned", "Painter's Servant",
      "mtgo commander unbanned", "Trade Secrets",
      "duel commander restricted", "Geist of Saint Traft",
      "duel commander restricted", "Jace, Vryn's Prodigy",
      "duel commander restricted", "Bruse Tarl, Boorish Herder",
      "duel commander banned", "Polymorph",
      "duel commander banned", "Emrakul, the Aeons Torn",
      "duel commander unbanned", "Ancient Tomb",
      "duel commander unbanned", "Mind Twist",
      "duel commander unbanned", "Fastbond"

    assert_banlist_changes "June 2017",
      "standard banned", "Aetherworks Marvel"

    assert_banlist_changes "May 2017",
      "mtgo commander banned", "Dig Through Time",
      "mtgo commander banned", "Strip Mine",
      "mtgo commander banned", "Treasure Cruise"

    assert_banlist_changes "April 2017",
      "legacy banned", "Sensei's Divining Top",
      "vintage restricted", "Gitaxian Probe",
      "vintage restricted", "Gush",
      "commander banned", "Leovold, Emissary of Trest",
      "commander unbanned", "Protean Hulk",
      "duel commander unrestricted", "Yisan, the Wanderer Bard",
      "duel commander banned", "Chrome Mox",
      "duel commander banned", "Mox Diamond",
      "duel commander restricted", "Breya, Etherium Shaper",
      "duel commander restricted", "Vial Smasher the Fierce",
      "standard banned", "Felidar Guardian"

    assert_banlist_changes "January 2017",
      "standard banned", "Emrakul, the Promised End",
      "standard banned", "Smuggler's Copter",
      "standard banned", "Reflector Mage",
      "modern banned", "Gitaxian Probe",
      "modern banned", "Golgari Grave-Troll"
  end

  it "banlist_2016" do
    assert_banlist_changes "January 2016",
      "modern banned", "Splinter Twin",
      "modern banned", "Summer Bloom",
      "pauper banned", "Cloud of Faeries"

    assert_banlist_changes "April 2016",
      "modern banned", "Eye of Ugin",
      "modern unbanned", "Ancestral Vision",
      "modern unbanned", "Sword of the Meek",
      "vintage restricted", "Lodestone Golem"

    assert_banlist_changes "November 2016",
      "pauper banned", "Peregrine Drake",
      "duel commander unbanned", "Yawgmoth's Bargain",
      "duel commander unbanned", "Serra Ascendant",
      "duel commander unbanned", "Grindstone",
      "duel commander unbanned", "Necropotence",
      "duel commander unbanned", "Balance"
  end

  it "banlist_2015" do
    assert_banlist_changes "September 2015",
      "legacy banned",  "Dig Through Time",
      "legacy unbanned", "Black Vise",
      "vintage restricted", "Chalice of the Void",
      "vintage unrestricted", "Thirst for Knowledge"

    assert_banlist_changes "March 2015",
      "pauper banned", "Treasure Cruise"

    assert_banlist_changes "January 2015",
      "modern banned", "Dig Through Time",
      "modern banned", "Treasure Cruise",
      "modern banned", "Birthing Pod",
      "legacy banned", "Treasure Cruise",
      "legacy unbanned", "Worldgorger Dragon",
      "vintage restricted", "Treasure Cruise",
      "vintage unrestricted", "Gifts Ungiven"
  end

  it "banlist_2014" do
    assert_banlist_changes "February 2014",
      "modern banned", "Deathrite Shaman",
      "modern unbanned", "Wild Nacatl",
      "modern unbanned", "Bitterblossom"
  end

  it "banlist_2013" do
    assert_banlist_changes "September 2013",
      "pauper banned", "Cloudpost",
      "pauper banned", "Temporal Fissure"

    assert_banlist_changes "May 2013",
      "modern banned", "Second Sunrise",
      "vintage unrestricted", "Regrowth"

    assert_banlist_changes "January 2013",
      "modern banned", "Bloodbraid Elf",
      "modern banned", "Seething Song",
      "pauper banned", "Empty the Warrens",
      "pauper banned", "Grapeshot",
      "pauper banned", "Invigorate"
  end

  it "banlist_2012" do
    assert_banlist_changes "September 2012",
      "modern unbanned", "Valakut, the Molten Pinnacle",
      "vintage unrestricted", "Burning Wish"

    assert_banlist_changes "June 2012",
      "legacy unbanned", "Land Tax"

    assert_banlist_changes "March 2012",
      "innistrad block banned", "Lingering Souls",
      "innistrad block banned", "Intangible Virtue"
  end

  it "banlist_2011" do
    # Weirdo exception for "War of Attrition" event deck ignored
    assert_banlist_changes "June 2011",
      "standard banned", "Jace, the Mind Sculptor",
      "standard banned", "Stoneforge Mystic"

    assert_banlist_changes "September 2011",
      "extended banned", "Jace, the Mind Sculptor",
      "extended banned", "Mental Misstep",
      "extended banned", "Ponder",
      "extended banned", "Preordain",
      "extended banned", "Stoneforge Mystic",
      "legacy banned", "Mental Misstep",
      "vintage unrestricted", "Fact or Fiction",
      "modern banned", "Blazing Shoal",
      "modern banned", "Cloudpost",
      "modern banned", "Green Sun's Zenith",
      "modern banned", "Ponder",
      "modern banned", "Preordain",
      "modern banned", "Rite of Flame"

    assert_banlist_changes "December 2011",
      "modern banned", "Punishing Fire",
      "modern banned", "Wild Nacatl"
  end

  it "initial_modern_banlist" do
    # August 2011
    assert_full_banlist "modern", "August 2011", [
      "Ancestral Vision",
      "Ancient Den",
      "Bitterblossom",
      "Chrome Mox",
      "Dark Depths",
      "Dread Return",
      "Glimpse of Nature",
      "Golgari Grave-Troll",
      "Great Furnace",
      "Hypergenesis",
      "Jace, the Mind Sculptor",
      "Mental Misstep",
      "Seat of the Synod",
      "Sensei's Divining Top",
      "Skullclamp",
      "Stoneforge Mystic",
      "Sword of the Meek",
      "Tree of Tales",
      "Umezawa's Jitte",
      "Valakut, the Molten Pinnacle",
      "Vault of Whispers",
    ]
  end

  it "banlist_2010" do
    assert_banlist_changes "June 2010",
      "extended banned", "Sword of the Meek",
      "extended banned", "Hypergenesis",
      "legacy banned", "Mystical Tutor",
      "legacy unbanned", "Grim Monolith",
      "legacy unbanned", "Illusionary Mask"

    assert_banlist_changes "September 2010",
      "vintage unrestricted", "Frantic Search",
      "vintage unrestricted", "Gush"

    assert_banlist_changes "December 2010",
      "legacy banned", "Survival of the Fittest",
      "legacy unbanned", "Time Spiral"
  end

  it "banlist_2009" do
    assert_banlist_changes "June 2009",
      "vintage restricted", "Thirst for Knowledge",
      "vintage unrestricted", "Crop Rotation",
      "vintage unrestricted", "Enlightened Tutor",
      "vintage unrestricted", "Entomb",
      "vintage unrestricted", "Grim Monolith"

    assert_banlist_changes "September 2009",
      "legacy unbanned", "Dream Halls",
      "legacy unbanned", "Entomb",
      "legacy unbanned", "Metalworker"
  end

  it "banlist_2008" do
    assert_banlist_changes "June 2008",
      "vintage restricted", "Brainstorm",
      "vintage restricted", "Flash",
      "vintage restricted", "Gush",
      "vintage restricted", "Merchant Scroll",
      "vintage restricted", "Ponder"

    assert_banlist_changes "September 2008",
      "extended banned", "Sensei's Divining Top",
      "legacy banned", "Time Vault",
      "vintage restricted", "Time Vault",
      "vintage unrestricted", "Chrome Mox",
      "vintage unrestricted", "Dream Halls",
      "vintage unrestricted", "Mox Diamond",
      "vintage unrestricted", "Personal Tutor",
      "vintage unrestricted", "Time Spiral"
  end

  it "banlist_2007" do
    assert_banlist_changes "June 2007",
      "vintage restricted", "Gifts Ungiven",
      "vintage unrestricted", "Voltaic Key",
      "vintage unrestricted", "Black Vise",
      "vintage unrestricted", "Mind Twist",
      "vintage unrestricted", "Gush",
      "legacy banned", "Flash",
      "legacy unbanned", "Mind Over Matter",
      "legacy unbanned", "Replenish"

    assert_banlist_changes "September 2007",
      "vintage banned", "Shahrazad",
      "legacy banned", "Shahrazad"
  end

  it "banlist_2006" do
    assert_banlist_changes "March 2006",
      "mirrodin block banned", "Aether Vial",
      "mirrodin block banned", "Ancient Den",
      "mirrodin block banned", "Arcbound Ravager",
      "mirrodin block banned", "Darksteel Citadel",
      "mirrodin block banned", "Disciple of the Vault",
      "mirrodin block banned", "Great Furnace",
      "mirrodin block banned", "Seat of the Synod",
      "mirrodin block banned", "Tree of Tales",
      "mirrodin block banned", "Vault of Whispers"
  end

  it "banlist_2005" do
    assert_banlist_changes "March 2005",
      "standard banned", "Arcbound Ravager",
      "standard banned", "Disciple of the Vault",
      "standard banned", "Darksteel Citadel",
      "standard banned", "Ancient Den",
      "standard banned", "Great Furnace",
      "standard banned", "Seat of the Synod",
      "standard banned", "Tree of Tales",
      "standard banned", "Vault of Whispers",
      "vintage restricted", "Trinisphere"

    assert_banlist_changes "September 2005",
      "extended banned", "Aether Vial",
      "extended banned", "Disciple of the Vault",
      "legacy banned", "Imperial Seal",
      "vintage restricted", "Imperial Seal",
      "vintage restricted", "Personal Tutor",
      "vintage unrestricted", "Mind Over Matter",
      "two-headed giant banned", "Erayo, Soratami Ascendant"
  end

  it "banlist_2004" do
    assert_banlist_changes "June 2004",
      "standard banned", "Skullclamp",
      "mirrodin block banned", "Skullclamp"

    assert_banlist_changes "September 2004",
      "extended banned", "Metalworker",
      "extended banned", "Skullclamp",
      "vintage unrestricted", "Braingeyser",
      "vintage unrestricted", "Doomsday",
      "vintage unrestricted", "Earthcraft",
      "vintage unrestricted", "Fork",
      # In September 2004 Legacy becomes independent of Vintage
      "legacy unbanned", "Braingeyser",
      "legacy unbanned", "Burning Wish",
      "legacy unbanned", "Chrome Mox",
      "legacy unbanned", "Crop Rotation",
      "legacy unbanned", "Doomsday",
      "legacy unbanned", "Enlightened Tutor",
      "legacy unbanned", "Fact or Fiction",
      "legacy unbanned", "Fork",
      "legacy unbanned", "Lion's Eye Diamond",
      "legacy unbanned", "Lotus Petal",
      "legacy unbanned", "Mox Diamond",
      "legacy unbanned", "Mystical Tutor",
      "legacy unbanned", "Regrowth",
      "legacy unbanned", "Stroke of Genius",
      "legacy unbanned", "Voltaic Key",
      "legacy banned", "Bazaar of Baghdad",
      "legacy banned", "Goblin Recruiter",
      "legacy banned", "Hermit Druid",
      "legacy banned", "Illusionary Mask",
      "legacy banned", "Land Tax",
      "legacy banned", "Mana Drain",
      "legacy banned", "Metalworker",
      "legacy banned", "Mishra's Workshop",
      "legacy banned", "Oath of Druids",
      "legacy banned", "Replenish",
      "legacy banned", "Skullclamp",
      "legacy banned", "Worldgorger Dragon"

    assert_banlist_changes "December 2004",
      "vintage unrestricted", "Stroke of Genius"
  end

  it "banlist_2003" do
    assert_banlist_changes "March 2003",
      "vintage+ unrestricted", "Berserk",
      "vintage+ unrestricted", "Hurkyl's Recall",
      "vintage+ unrestricted", "Recall" ,
      "vintage+ restricted", "Earthcraft",
      "vintage+ restricted", "Entomb"

    assert_banlist_changes "June 2003",
      "vintage+ restricted", "Gush",
      "vintage+ restricted", "Mind's Desire"

    assert_banlist_changes "September 2003",
      "extended banned", "Goblin Lackey",
      "extended banned", "Entomb",
      "extended banned", "Frantic Search"

    assert_banlist_changes "December 2003",
      "extended banned", "Goblin Recruiter",
      "extended banned", "Grim Monolith",
      "extended banned", "Tinker",
      "extended banned", "Hermit Druid",
      "extended banned", "Ancient Tomb",
      "extended banned", "Oath of Druids",
      "vintage+ restricted", "Burning Wish",
      "vintage+ restricted", "Chrome Mox",
      "vintage+ restricted", "Lion's Eye Diamond"
  end

  it "banlist_2002" do
    # No changes whole year
  end

  it "banlist_2001" do
    assert_banlist_changes "March 2001",
      "extended banned", "Necropotence",
      "extended banned", "Replenish",
      "extended banned", "Survival of the Fittest",
      "extended banned", "Demonic Consultation"

    assert_banlist_changes "December 2001",
      "vintage+ restricted", "Fact or Fiction"
  end

  it "banlist_2000" do
    assert_banlist_changes "March 2000",
      "extended banned", "Dark Ritual",
      "extended banned", "Mana Vault"

    assert_banlist_changes "June 2000",
      "masques block banned", "Lin Sivvi, Defiant Hero",
      "masques block banned", "Rishadan Port"

    assert_banlist_changes "September 2000",
      "vintage banned-to-restricted", "Channel",
      "vintage banned-to-restricted", "Mind Twist",
      "vintage+ restricted", "Demonic Consultation",
      "vintage+ restricted", "Necropotence"
  end


  it "banlist_1999" do
    assert_banlist_changes "mar 1999",
      "standard banned", "Dream Halls",
      "standard banned", "Earthcraft",
      "standard banned", "Fluctuator",
      "standard banned", "Lotus Petal",
      "standard banned", "Recurring Nightmare",
      "standard banned", "Time Spiral",
      "standard banned", "Memory Jar", # banned retroactively in mid in mid March.
      "extended banned", "Memory Jar", # banned retroactively in mid in mid March.
      "urza block banned", "Time Spiral",
      "urza block banned", "Memory Jar",
      "urza block banned", "Windfall",
      # This is literally impossible according to "legacy and vintage unlinked sep 2004" theory
      # but that's what http://members.tripod.com/blue_midget/Gossip/banned.htm says
      # "legacy unbanned", "Candelabra of Tawnos",
      # "legacy unbanned", "Copy Artifact",
      # "legacy unbanned", "Maze of Ith",
      # "legacy unbanned", "Zuran Orb",
      # "legacy unbanned", "Mishra's Workshop",
      # "legacy banned", "Time Spiral",
      # "legacy banned", "Memory Jar",
      # "vintage+ unrestricted", "Maze of Ith",
      "vintage+ restricted", "Time Spiral"

    assert_banlist_changes "jun 1999",
      "standard banned", "Mind Over Matter",
      "extended banned", "Time Spiral",
      "urza block banned", "Gaea's Cradle",
      "urza block banned", "Serra's Sanctum",
      "urza block banned", "Tolarian Academy",
      "urza block banned", "Voltaic Key"

    assert_banlist_changes "jul 1999",
      "extended banned", "Yawgmoth's Bargain"

    assert_banlist_changes "sep 1999",
      "extended banned", "Dream Halls",
      "extended banned", "Earthcraft",
      "extended banned", "Lotus Petal",
      "extended banned", "Mind Over Matter",
      "extended banned", "Yawgmoth's Will",
      # "vintage+ unbanned", "Divine Intervention",
      "vintage+ unbanned", "Shahrazad",
      "vintage+ unrestricted", "Ivory Tower",
      # "vintage+ unrestricted", "Mirror Universe",
      # "vintage+ unrestricted", "Underworld Dreams",
      "vintage+ restricted", "Crop Rotation",
      "vintage+ restricted", "Doomsday",
      "vintage+ restricted", "Dream Halls",
      "vintage+ restricted", "Enlightened Tutor",
      "vintage+ restricted", "Frantic Search",
      "vintage+ restricted", "Grim Monolith",
      "vintage+ restricted", "Hurkyl's Recall",
      "vintage+ restricted", "Lotus Petal",
      "vintage+ restricted", "Mana Crypt",
      "vintage+ restricted", "Mana Vault",
      "vintage+ restricted", "Mind Over Matter",
      "vintage+ restricted", "Mox Diamond",
      "vintage+ restricted", "Mystical Tutor",
      "vintage+ restricted", "Tinker",
      "vintage+ restricted", "Vampiric Tutor",
      "vintage+ restricted", "Voltaic Key",
      "vintage+ restricted", "Yawgmoth's Bargain",
      "vintage+ restricted", "Yawgmoth's Will"
  end

  it "banlist_1998" do
    assert_banlist_changes "December 1998",
      "standard banned", "Tolarian Academy",
      "standard banned", "Windfall",
      "extended banned", "Tolarian Academy",
      "extended banned", "Windfall",
      # "extended unbanned", "Braingeyser",
      # This is not supposed to happen:
      # "legacy unbanned", "Feldon's Cane",
      "vintage+ restricted", "Stroke of Genius",
      "vintage+ restricted", "Tolarian Academy",
      "vintage+ restricted", "Windfall"
  end

  it "banlist_1997" do
    assert_banlist_changes "April 1997",
      "ice age block banned", "Thawing Glaciers",
      "ice age block banned", "Zuran Orb"

    assert_banlist_changes "June 1997",
      "standard banned", "Zuran Orb",
      "vintage+ restricted", "Black Vise",
      "mirage block banned", "Squandered Resources"

    assert_banlist_changes "September 1997",
      "extended banned", "Hypnotic Specter",
      # "extended unbanned", "Juggernaut",
      "vintage+ unrestricted", "Candelabra of Tawnos",
      "vintage+ unrestricted", "Copy Artifact",
      "vintage+ unrestricted", "Feldon's Cane"
      # "vintage+ unrestricted", "Mishra's Workshop",
      # "vintage+ unrestricted", "Zuran Orb"
  end

  it "banlist_1996" do
    assert_banlist_changes "January 1996",
      "standard banned", "Mind Twist",
      "standard restricted", "Black Vise",
      "vintage+ banned", "Mind Twist",
      "vintage+ restricted", "Black Vise"

    assert_banlist_changes "March 1996",
      # "standard unrestricted", "Feldon's Cane",
      # "standard unrestricted", "Maze of Ith",
      # "standard unrestricted", "Recall",
      "vintage+ unbanned", "Time Vault",
      "vintage+ unrestricted", "Ali from Cairo",
      # "vintage+ unrestricted", "Sword of the Ages",
      "vintage+ unrestricted", "Black Vise"

    assert_banlist_changes "June 1996",
      "standard restricted", "Land Tax"

    assert_banlist_changes "September 1996",
      "standard restricted", "Hymn to Tourach",
      "standard restricted", "Strip Mine",
      "vintage+ restricted", "Fastbond"

    # December 1996: Standard: All cards on the restricted list are moved to the banned list.
    # I added that to BanList, but reliability of data so old is so low that I'm not even going to test that
  end

  it "banlist_1995" do
    assert_banlist_changes "April 1995",
      "vintage+ restricted", "Balance",
      "standard restricted", "Balance"
  end

  it "banlist_1994" do
    assert_full_banlist "vintage", "January 1, 1994", [
      "Contract from Below",
      "Darkpact",
      "Demonic Attorney",
      "Jeweled Bird",
      "Bronze Tablet", # all ante cards are banned in advance
      "Amulet of Quoz",
      "Timmerian Fiends",
      "Tempest Efreet",
      "Rebirth",
      "Chaos Orb",
      "Falling Star",
      "Shahrazad",
    ], [
      "Ali from Cairo",
      "Ancestral Recall",
      "Berserk",
      "Black Lotus",
      "Braingeyser",
      "Dingus Egg",
      "Gauntlet of Might",
      "Icy Manipulator",
      "Mox Pearl",
      "Mox Emerald",
      "Mox Ruby",
      "Mox Sapphire",
      "Mox Jet",
      "Orcish Oriflamme",
      "Rukh Egg",
      "Sol Ring",
      "Timetwister",
      "Time Vault",
      "Time Walk",
    ]

    assert_banlist_changes "May 1994",
      "vintage+ restricted", "Candelabra of Tawnos",
      "vintage+ restricted", "Channel",
      "vintage+ restricted", "Copy Artifact",
      "vintage+ restricted", "Demonic Tutor",
      "vintage+ restricted", "Feldon's Cane",
      "vintage+ restricted", "Ivory Tower",
      "vintage+ restricted", "Library of Alexandria",
      "vintage+ restricted", "Regrowth",
      "vintage+ restricted", "Wheel of Fortune",
      "vintage+ restricted-to-banned", "Time Vault",
      "vintage+ unrestricted", "Dingus Egg",
      "vintage+ unrestricted", "Gauntlet of Might",
      "vintage+ unrestricted", "Icy Manipulator",
      "vintage+ unrestricted", "Orcish Oriflamme",
      "vintage+ unrestricted", "Rukh Egg",
      "vintage+ restricted", "Fork",
      "vintage+ restricted", "Recall"
  end

  it "banlist_1993" do
    # Everything was legal back then
  end

  ##################################################

  it "legacy_vintage_split" do
    assert_full_banlist "legacy", "September 20, 2004", [
      "Amulet of Quoz",
      "Ancestral Recall",
      "Balance",
      "Bazaar of Baghdad",
      "Black Lotus",
      "Black Vise",
      "Bronze Tablet",
      "Channel",
      "Chaos Orb",
      "Contract from Below",
      "Darkpact",
      "Demonic Attorney",
      "Demonic Consultation",
      "Demonic Tutor",
      "Dream Halls",
      "Earthcraft",
      "Entomb",
      "Falling Star",
      "Fastbond",
      "Frantic Search",
      "Goblin Recruiter",
      "Grim Monolith",
      "Gush",
      "Hermit Druid",
      "Illusionary Mask",
      "Jeweled Bird",
      "Land Tax",
      "Library of Alexandria",
      "Mana Crypt",
      "Mana Drain",
      "Mana Vault",
      "Memory Jar",
      "Metalworker",
      "Mind Over Matter",
      "Mind Twist",
      "Mind's Desire",
      "Mishra's Workshop",
      "Mox Emerald",
      "Mox Jet",
      "Mox Pearl",
      "Mox Ruby",
      "Mox Sapphire",
      "Necropotence",
      "Oath of Druids",
      "Rebirth",
      "Replenish",
      "Skullclamp",
      "Sol Ring",
      "Strip Mine",
      "Tempest Efreet",
      "Time Spiral",
      "Time Walk",
      "Timetwister",
      "Timmerian Fiends",
      "Tinker",
      "Tolarian Academy",
      "Vampiric Tutor",
      "Wheel of Fortune",
      "Windfall",
      "Worldgorger Dragon",
      "Yawgmoth's Bargain",
      "Yawgmoth's Will",
    ]
  end

  it "legacy_was_just_vintage_plus_before_split" do
    cutoff_date = Date.parse("2004-09-20")
    BanList.all_change_dates.each do |date|
      legacy_banlist  = BanList["legacy"].full_ban_list(date)
      vintage_banlist = BanList["vintage"].full_ban_list(date)
      vintage_plus_banlist = Hash[vintage_banlist.map{|k,v| [k, v == "restricted" ? "banned" : v]}]
      if date < cutoff_date
        legacy_banlist.should eq(vintage_plus_banlist)
      else
        legacy_banlist.should_not eq(vintage_plus_banlist)
      end
    end
  end

  it "legends_restricted" do
    # assert false, "summon legend restricted until 1995"
  end

  it "format_legality_changes" do
    # Starter Level sets Starter 1999, Starter 2000, Portal, Portal Second Age, and Portal Three Kingdoms become legal in Legacy and Vintage in October.
    # assert false, "This should go to another test"
    # Also all Exended variants etc. None of that belongs here
  end

  ##################################################
  # Formats in mtgjson are verified by indexer
  # Formats not in mtgjson should all be listed here
  # FIXME: (that was with v3, no longer true)

  it "pauper_banlist_now" do
    assert_full_banlist "pauper", "1 October 2015", [
      "Cranial Plating",
      "Frantic Search",
      "Empty the Warrens",
      "Grapeshot",
      "Invigorate",
      "Cloudpost",
      "Temporal Fissure",
      "Treasure Cruise",
    ]
  end

  it "MTGO commander now" do
    assert_full_banlist "mtgo commander", "4 May 2017", [
      "Black Lotus",
      "Channel",
      "Fastbond",
      "Gaea's Cradle",
      "Mana Crypt",
      "Mana Vault",
      "Mishra's Workshop",
      "Mox Emerald",
      "Mox Jet",
      "Mox Pearl",
      "Mox Ruby",
      "Mox Sapphire",
      "Sol Ring",
      "Tolarian Academy",
      "Bazaar of Baghdad",
      "Doomsday",
      "Entomb",
      "Food Chain",
      "Gifts Ungiven",
      "Hermit Druid",
      "Protean Hulk",
      "Survival of the Fittest",
      "Time Vault",
      "Tinker",
      "Yawgmoth's Bargain",
      "Arcum Dagsson",
      "Braids, Cabal Minion",
      "Derevi, Empyrial Tactician",
      "Edric, Spymaster of Trest",
      "Erayo, Soratami Ascendant",
      "Erayo's Essence",
      "Griselbrand",
      "Rofellos, Llanowar Emissary",
      "Yisan, the Wanderer Bard",
      "Zur the Enchanter",
      "Ancestral Recall",
      "Back to Basics",
      "Balance",
      "Humility",
      "Karakas",
      "Library of Alexandria",
      "Mana Drain",
      "Mind Twist",
      "Moat",
      "Natural Order",
      "Necropotence",
      "Oath of Druids",
      "Serra Ascendant",
      "The Tabernacle at Pendrell Vale",
      "Time Walk",
      "Biorhythm",
      "Limited Resources",
      "Painter's Servant",
      "Sensei's Divining Top",
      "Trade Secrets",
      "Amulet of Quoz",
      "Bronze Tablet",
      "Chaos Orb",
      "Contract from Below",
      "Darkpact",
      "Demonic Attorney",
      "Falling Star",
      "Jeweled Bird",
      "Rebirth",
      "Shahrazad",
      "Tempest Efreet",
      "Timmerian Fiends",
    ]
  end

  it "two_headed_giant_banlist_now" do
    assert_full_banlist "two-headed giant", "1 October 2015", [
      "Erayo, Soratami Ascendant",
    ]
  end

  it "ban_events_for" do
    BanList["mtgo commander"].events.should include(
      [
        Date.parse("2017-10-11"),
        "http://wizardsmtgo.tumblr.com/post/166220048834/mtgo-commander-1v1-banned-announcement",
        [
          {:name=>"Arcum Dagsson", :old=>"banned", :new=>"legal"},
           {:name=>"Yisan, the Wanderer Bard", :old=>"banned", :new=>"legal"},
           {:name=>"Baral, Chief of Compliance", :old=>"legal", :new=>"banned"},
           {:name=>"Demonic Tutor", :old=>"legal", :new=>"banned"},
           {:name=>"Emrakul, the Aeons Torn", :old=>"legal", :new=>"banned"},
           {:name=>"Enlightened Tutor", :old=>"legal", :new=>"banned"},
           {:name=>"Imperial Seal", :old=>"legal", :new=>"banned"},
           {:name=>"Mystical Tutor", :old=>"legal", :new=>"banned"},
           {:name=>"Vampiric Tutor", :old=>"legal", :new=>"banned"},
        ]
      ]
    )
  end

  it "all ban events have correctly named cards" do
    Format.all_format_classes.each do |format_class|
      format_class.new.ban_events.each do |_, _, cards|
        cards.each do |card|
          name = card[:name]
          db.has_card_named?(name).should eq(true), "Card named `#{name}' should exist"
        end
      end
    end
  end
end

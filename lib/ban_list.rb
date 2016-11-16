BanListChangeDates = {
  # magic min/max, might not end up being needed
  "start" => "1900-01-01",
  "end"   => "2999-12-31",

  "mar 1994" => "1.4.1994", # guess
  # https://groups.google.com/forum/message/raw?msg=rec.games.deckmaster/P4K--JAyLvE/WCYfShI7arQJ
  "may 1994" => "2.5.1994",

  "apr 1995" => "1.5.1995", # guess
  "jan 1996" => "1.2.1996", # guess
  "mar 1996" => "1.4.1996", # guess
  "jun 1996" => "1.7.1996", # guess
  "dec 1996" => "1.1.1997", # guess
  "sep 1996" => "1.10.1996",# guess
  "sep 1997" => "1.10.1997",# guess
  "dec 1998" => "1.1.1999", # guess

   # originals are gone, guessing exact date based on patterns:
  "apr 1997" => "1 may 1997",
  "jun 1997" => "1 jul 1997",
  "mar 1998" => "1 apr 1998",

  # http://members.tripod.com/blue_midget/Gossip/banned.htm
  "mar 1999" => "April 1, 1999",

  # For 1999+ annoncemenets are at:
  # http://mtg.icequake.net/www.crystalkeep.com/magic/rules/dci/

  "jun 1999" => "July 1, 1999",
  "jul 1999" => "August 1, 1999", # emergency ban
  "sep 1999" => "October 1, 1999",
  "mar 2000" => "April 1, 2000",
  "jun 2000" => "July 1, 2000",
  "sep 2000" => "October 1, 2000",
  "mar 2001" => "April 1, 2001",
  "dec 2001" => "January 1, 2002",
  "mar 2003" => "April 1, 2003",
  "jun 2003" => "July 1, 2003",

  "sep 2003" => "October 1, 2003",
  "dec 2003" => "January 1, 2004",

  "sep 2004" => "September 20, 2004",
  "dec 2004" => "December 20, 2004",
  "mar 2005" => "March 20, 2005",
  "jun 2007" => "June 20, 2007",
  "jun 2008" => "June 20, 2008",
  "sep 2005" => "September 20, 2005",
  "jun 2004" => "June 20, 2004",
  "mar 2006" => "March 20, 2006",
  "sep 2007" => "September 20, 2007",
  "sep 2008" => "September 20, 2008",

  "jun 2009" => "July 1, 2009",
  "sep 2009" => "October 1, 2009",

  "jun 2010" => "July 1, 2010",
  "sep 2010" => "October 1, 2010",
  "dec 2010" => "January 1, 2011",
  "jun 2011" => "July 1, 2011",
  # "aug 2011"   - modern annoncement, just encoded as "start"
  "sep 2011" => "1.10.2011", # "October 1, 2011" but ISD released between announcement and effective date
  "dec 2011" => "January 1, 2012",
  "mar 2012" => "April 1, 2012", # April 2, 2012, making script's life easier
  "jun 2012" => "June 29, 2012",
  "sep 2012" => "October 1, 2012",

   # September 20, 2012 - was policy change, before that there were 4 anonucements per year
   # After that, it's linked with set release
   # This list should be culled a bit to just relevant ones
   "rtr"=>"2012-10-05",
   "gtc"=>"2013-02-01",
   "dgm"=>"2013-05-03",
   "m14"=>"2013-07-19",
   "ths"=>"2013-09-27",
   "bng"=>"2014-02-07",
   "jou"=>"2014-05-02",
   "m15"=>"2014-07-18",
   "ktk"=>"2014-09-26",
   "frf"=>"2015-01-23",
   "dtk"=>"2015-03-27",
   "ori"=>"2015-07-17",
   "bfz"=>"2015-10-02",
   "ogw"=>"2016-01-22",
   "soi"=>"2016-04-08",

  # Irregular emergency ban
  # http://magic.wizards.com/en/articles/archive/magic-online/pauper-banned-list-change-2016-11-03
  "16 nov 2016" => "16 nov 2016",

  # Aliases
  "may 2013" => "2013-05-03",

  # EDH dates, round up to nearest vanilla date or nearest 1st
  # can't round down because tests assume it's >
  # TODO: get real dates
  "oct 2002" => "2 oct 2002",
  "may 2003" => "2 may 2003",
  "oct 2004" => "2 oct 2004",
  "apr 2005" => "2 apr 2005",
  "dec 2005" => "2 dec 2005",
  "feb 2006" => "2 feb 2006",
  "may 2006" => "2 may 2006",
  "nov 2006" => "2 nov 2006",
  "mar 2007" => "2 mar 2007",
  "feb 2008" => "2 feb 2008",
  "dec 2008" => "2 dec 2008",
  "mar 2009" => "2 mar 2009",
  "dec 2009" => "2 dec 2009",
  "apr 2013" => "2 apr 2013",
  # EDH, can match set releases
  "feb 2014" => "2014-02-07",
  "sep 2014" => "2014-09-26",
}

DynamicBanListData = {
  ### THESE LISTS SHOULD BE COMPLETE AND ACCURATE

  "modern" => {
    "Ancestral Vision" => {"start" => "banned", "soi" => "legal"},
    "Ancient Den" => "banned",
    "Bitterblossom" => {"start"=>"banned", "bng" => "legal"},
    "Chrome Mox" => "banned",
    "Dark Depths" => "banned",
    "Dread Return" => "banned",
    "Glimpse of Nature" => "banned",
    "Great Furnace" => "banned",
    "Hypergenesis" => "banned",
    "Jace, the Mind Sculptor" => "banned",
    "Mental Misstep" => "banned",
    "Seat of the Synod" => "banned",
    "Sensei's Divining Top" => "banned",
    "Skullclamp" => "banned",
    "Stoneforge Mystic" => "banned",
    "Sword of the Meek" => {"start" => "banned", "soi" => "legal"},
    "Tree of Tales" => "banned",
    "Umezawa's Jitte" => "banned",
    "Vault of Whispers" => "banned",
    "Eye of Ugin" => {"soi" => "banned"},

    "Deathrite Shaman"  => {"bng"=> "banned"},
    "Dig Through Time"  => {"frf"=> "banned"},
    "Treasure Cruise"   => {"frf"=> "banned"},
    "Birthing Pod"      => {"frf"=> "banned"},

    "Golgari Grave-Troll"  => {"start"=>"banned", "frf" => "legal"},
    "Valakut, the Molten Pinnacle" => {"start"=>"banned", "sep 2012"=>"legal"},
    "Wild Nacatl"       => {"dec 2011"=>"banned", "bng"=>"legal"},
    "Punishing Fire"    => {"dec 2011"=>"banned"},

    "Blazing Shoal"      => { "sep 2011"=>"banned"},
    "Cloudpost"          => { "sep 2011"=>"banned"},
    "Green Sun's Zenith" => { "sep 2011"=>"banned"},
    "Ponder"             => { "sep 2011"=>"banned"},
    "Preordain"          => { "sep 2011"=>"banned"},
    "Rite of Flame"      => { "sep 2011"=>"banned"},

    "Bloodbraid Elf"  => {"gtc" => "banned"},
    "Seething Song"   => {"gtc" => "banned"},
    "Second Sunrise"  => { "dgm" => "banned" },

    "Summer Bloom"  => {"ogw" => "banned"},
    "Splinter Twin" => {"ogw" => "banned"},
  },
  "innistrad block" => {
    "Lingering Souls"    => {"start"=>"legal", "mar 2012"=>"banned"},
    "Intangible Virtue"  => {"start"=>"legal", "mar 2012"=>"banned"},
  },
  "pauper" => {
    # No idea when Cranial Plating was banned,
    # it says in Nov 2008 that it's already banned
    "Cranial Plating"   => {"start" => "banned"},
    "Frantic Search"    => {"jun 2011" => "banned"},
    "Empty the Warrens" => {"gtc" => "banned"},
    "Grapeshot"         => {"gtc" => "banned"},
    "Invigorate"        => {"gtc" => "banned"},
    "Cloudpost"         => {"ths" => "banned"},
    "Temporal Fissure"  => {"ths" => "banned"},
    "Treasure Cruise"   => {"dtk" => "banned"},
    "Cloud of Faeries"  => {"ogw" => "banned"},
    "Peregrine Drake"   => {"16 nov 2016" => "banned"},
  },
  "two-headed giant" => {
    "Erayo, Soratami Ascendant" => {"sep 2005" => "banned"},
  },
  "masques block" => {
    "Lin Sivvi, Defiant Hero" => { "jun 2000" => "banned" },
    "Rishadan Port"           => { "jun 2000" => "banned" },
  },
  "mirrodin block" => {
    "Skullclamp"           => { "jun 2004" => "banned" },
    # WTF??? This was deep in Ravnica block
    "Aether Vial"          => { "mar 2006" => "banned" },
    "Ancient Den"          => { "mar 2006" => "banned" },
    "Arcbound Ravager"     => { "mar 2006" => "banned" },
    "Darksteel Citadel"    => { "mar 2006" => "banned" },
    "Disciple of the Vault"=> { "mar 2006" => "banned" },
    "Great Furnace"        => { "mar 2006" => "banned" },
    "Seat of the Synod"    => { "mar 2006" => "banned" },
    "Tree of Tales"        => { "mar 2006" => "banned" },
    "Vault of Whispers"    => { "mar 2006" => "banned" },
  },
  "ice age block" => {
    "Thawing Glaciers" => {"apr 1997" => "banned"},
    "Zuran Orb" => {"apr 1997" => "banned"},
    "Amulet of Quoz" => "banned",
  },
  "mirage block" => {
    "Squandered Resources" => {"jun 1997" => "banned"},
  },
  "urza block" => {
    "Time Spiral"             => { "mar 1999" => "banned" },
    "Memory Jar"              => { "mar 1999" => "banned" },
    "Windfall"                => { "mar 1999" => "banned" },
    "Gaea's Cradle"           => { "jun 1999" => "banned" },
    "Serra's Sanctum"         => { "jun 1999" => "banned" },
    "Tolarian Academy"        => { "jun 1999" => "banned" },
    "Voltaic Key"             => { "jun 1999" => "banned" },
  },

  ### Nothing below this line is guaranteed to be complete
  ### This should be possible to complete
  "tempest block" => {
    "Cursed Scroll" => "banned",
  },

  "commander" => {
    # Conspiracy cards are all banned
    "Advantageous Proclamation" => "banned",
    "Backup Plan" => "banned",
    "Brago's Favor" => "banned",
    "Double Stroke" => "banned",
    "Immediate Action" => "banned",
    "Iterative Analysis" => "banned",
    "Muzzio's Preparations" => "banned",
    "Power Play" => "banned",
    "Secret Summoning" => "banned",
    "Secrets of Paradise" => "banned",
    "Sentinel Dispatch" => "banned",
    "Unexpected Potential" => "banned",
    "Worldknit" => "banned",
    # Gatherer claims these have nil legality, whatever that means
    # "Aether Searcher" => nil,
    # "Agent of Acquisitions" => nil,
    # "Canal Dredger" => nil,
    # "Cogwork Grinder" => nil,
    # "Cogwork Librarian" => nil,
    # "Cogwork Spy" => nil,
    # "Cogwork Tracker" => nil,
    # "Deal Broker" => nil,
    # "Lore Seeker" => nil,
    # "Lurking Automaton" => nil,
    # "Paliano, the High City" => nil,
    # "Whispergear Sneak" => nil,
    # The rest

    # Vintage banned are EDH banned
    "Contract from Below" => "banned",
    "Darkpact" => "banned",
    "Demonic Attorney" => "banned",
    "Chaos Orb" => "banned",
    "Tempest Efreet" => "banned",
    "Amulet of Quoz" => "banned",
    "Timmerian Fiends" => "banned",
    "Jeweled Bird" => "banned",
    "Bronze Tablet" => "banned",
    "Falling Star" => "banned",
    "Rebirth" => "banned",
    # Was on and off Vintage list
    # sep 2007 removed from EDH banlist because it's already banned as vintage-banned card
    "Shahrazad" => { "start" => "banned", "sep 1999" => "legal", "dec 2005" => "banned" },
    # Was Vintage banned for a while
    "Time Vault"              => { "start" => "banned", "mar 1996" => "legal", "dec 2008" => "banned" },
    # Due to vintage ban, then specific ban
    "Channel"                 => { "jan 1996" => "banned", "sep 2000" => "legal", "jun 2010" => "banned"},
    # Just Vintage
    "Mind Twist"              => { "jan 1996" => "banned", "sep 2000" => "legal"},
    # Various bans
    "Ancestral Recall" => {"apr 2005" => "banned"},
    "Balance" => {"apr 2005" => "banned"},
    "Biorhythm" => {"apr 2005" => "banned"},
    "Black Lotus" => {"apr 2005" => "banned"},
    "Burning Wish" => {"may 2003" => "banned", "oct 2004" => "legal"},
    "Coalition Victory" => {"mar 2007" => "banned"},
    "Crucible of Worlds" => {"dec 2005" => "banned", "mar 2009" => "legal"},
    "Cunning Wish" => {"may 2003" => "banned", "oct 2004" => "legal"},
    "Death Wish" => {"may 2003" => "banned", "oct 2004" => "legal"},
    "Emrakul, the Aeons Torn" => {"dec 2010" => "banned"},
    "Enlightened Wish" => {"may 2003" => "banned", "oct 2004" => "legal"},
    "Grindstone" => {"sep 2008" => "banned", "dec 2009" => "legal"},
    "Griselbrand" => {"jun 2012" => "banned"},
    "Heartless Hidetsugu" => {"feb 2006" => "restricted", "nov 2006" => "legal"},
    "Karakas" => {"sep 2008" => "banned"},
    "Library of Alexandria" => {"apr 2005" => "banned"},
    "Limited Resources" => {"jun 2008" => "banned"},
    "Lion's Eye Diamond" => {"sep 2008" => "banned", "sep 2011" => "legal"},
    "Living Wish" => {"may 2003" => "banned", "oct 2004" => "legal"},
    "Mox Emerald" => {"apr 2005" => "banned"},
    "Mox Jet" => {"apr 2005" => "banned"},
    "Mox Pearl" => {"apr 2005" => "banned"},
    "Mox Ruby" => {"apr 2005" => "banned"},
    "Mox Sapphire" => {"apr 2005" => "banned"},
    "Niv-Mizzet, the Firemind" => {"feb 2006" => "restricted", "nov 2006" => "legal"},
    "Painter's Servant" => {"dec 2009" => "banned"},
    "Panoptic Mirror" => {"apr 2005" => "banned"},
    "Primeval Titan" => {"sep 2012" => "banned"},
    "Prophet of Kruphix" => {"ogw" => "banned"},
    "Protean Hulk" => {"sep 2008" => "banned"},
    "Recurring Nightmare" => {"feb 2008" => "banned"},
    "Riftsweeper" => {"sep 2008" => "banned", "sep 2009" => "legal"},
    "Staff of Domination" => {"jun 2010" => "banned", "apr 2013" => "legal"},
    "Sundering Titan" => {"jun 2012" => "banned"},
    "Sway of the Stars" => {"apr 2005" => "banned"},
    "Sylvan Primordial" => {"feb 2014" => "banned"},
    "Time Walk" => {"apr 2005" => "banned"},
    "Tinker" => {"mar 2009" => "banned"},
    "Tolarian Academy" => {"jun 2010" => "banned"},
    "Trade Secrets" => {"apr 2013" => "banned"},
    "Upheaval" => {"apr 2005" => "banned"},
    "Worldfire" => {"sep 2012" => "banned"},
    "Worldgorger Dragon" => {"apr 2005" => "banned", "jun 2011" => "legal"},
    "Braids, Cabal Minion" => {"jun 2009" => "restricted", "sep 2014" => "banned"},
    "Kokusho, the Evening Star" => {"feb 2008" => "banned", "sep 2012" => "restricted", "sep 2014" => "legal"},
    "Fastbond" => {"jun 2009" => "banned"},
    "Gifts Ungiven" => {"jun 2009" => "banned"},
    "Yawgmoth's Bargain" => {"may 2006" => "banned"},
    "Metalworker" => {"mar 2009" => "banned", "sep 2014" => "legal"},
    "Erayo's Essence" => {"sep 2011" => "restricted", "sep 2014" => "banned"},
    "Erayo, Soratami Ascendant" => {"sep 2011" => "restricted", "sep 2014" => "banned"},

    "Rofellos, Llanowar Emissary" => {"mar 2007" => "restricted", "mar 2009" => "legal", "jun 2010" => "restricted", "sep 2014" => "banned"},

    "Test of Endurance" => {"oct 2002" => "banned", "sep 2008" => "legal"},
    # Can't find any ban announcement
    # "Beacon of Immortality" => {"nov 2007" => "legal"},
  },

  ### DATA IS PARTIALLY CORRUPT, CAN'T RECOVER OLD FORMATS
  # As much as I managed to recover it, it should be fine

  "standard" => {
    # March 1996 Standard: Feldon's Cane , Maze of Ith , and Recall are unrestricted.
    "Jace, the Mind Sculptor" => { "jun 2011" => "banned" },
    "Stoneforge Mystic"       => { "jun 2011" => "banned" }, # ignoring Event Deck exception
    "Skullclamp"              => { "jun 2004" => "banned" },
    "Arcbound Ravager"        => { "mar 2005" => "banned" },
    "Disciple of the Vault"   => { "mar 2005" => "banned" },
    "Darksteel Citadel"       => { "mar 2005" => "banned", "jun 2011" => "legal" },  # de facto unbanned by rotation, just put random date there
    "Ancient Den"             => { "mar 2005" => "banned" },
    "Great Furnace"           => { "mar 2005" => "banned" },
    "Seat of the Synod"       => { "mar 2005" => "banned" },
    "Tree of Tales"           => { "mar 2005" => "banned" },
    "Vault of Whispers"       => { "mar 2005" => "banned" },
    "Mind Twist"              => { "jan 1996" => "banned" },
    "Mind Over Matter"        => { "jun 1999" => "banned" },
    "Land Tax"                => { "jun 1996" => "restricted", "dec 1996" => "banned" },
    "Balance"                 => { "apr 1995" => "restricted", "dec 1996" => "banned" },
    "Black Vise"              => { "jan 1996" => "restricted", "dec 1996" => "banned" },
    "Hymn to Tourach"         => { "sep 1996" => "restricted", "dec 1996" => "banned" },
    "Strip Mine"              => { "sep 1996" => "restricted", "dec 1996" => "banned" },
    "Zuran Orb"               => { "jun 1997" => "banned" },
    "Tolarian Academy"        => { "dec 1998" => "banned" },
    "Windfall"                => { "dec 1998" => "banned" },
    "Dream Halls"             => { "mar 1999" => "banned" },
    "Earthcraft"              => { "mar 1999" => "banned" },
    "Fluctuator"              => { "mar 1999" => "banned" },
    "Lotus Petal"             => { "mar 1999" => "banned" },
    "Recurring Nightmare"     => { "mar 1999" => "banned" },
    "Time Spiral"             => { "mar 1999" => "banned" },
    "Memory Jar"              => { "mar 1999" => "banned" },
  },

  "extended" => {
    "Hypnotic Specter"        => { "sep 1997" => "banned" },
    # "Juggernaut"              => { "sep 1997" => "unbanned" }, # Data here is obviously corrupt
    "Tolarian Academy"        => { "dec 1998" => "banned" },
    "Windfall"                => { "dec 1998" => "banned" },
    # "Braingeyser"             => { "dec 1998" => "unbanned" }, # Data here is obviously corrupt
    "Memory Jar"              => { "mar 1999" => "banned" },
    "Time Spiral"             => { "jun 1999" => "banned" },
    "Yawgmoth's Bargain"      => { "jul 1999" => "banned" },
    "Dream Halls"             => { "sep 1999" => "banned" },
    "Earthcraft"              => { "sep 1999" => "banned" },
    "Lotus Petal"             => { "sep 1999" => "banned" },
    "Mind Over Matter"        => { "sep 1999" => "banned" },
    "Yawgmoth's Will"         => { "sep 1999" => "banned" },
    "Dark Ritual"             => { "mar 2000" => "banned" },
    "Mana Vault"              => { "mar 2000" => "banned" },
    "Aether Vial"             => { "sep 2005" => "banned" },
    "Ancient Tomb"            => { "dec 2003" => "banned" },
    "Demonic Consultation"    => { "mar 2001" => "banned" },
    "Disciple of the Vault"   => { "sep 2005" => "banned" },
    "Entomb"                  => { "sep 2003" => "banned" },
    "Frantic Search"          => { "sep 2003" => "banned" },
    "Goblin Lackey"           => { "sep 2003" => "banned" },
    "Goblin Recruiter"        => { "dec 2003" => "banned" },
    "Grim Monolith"           => { "dec 2003" => "banned" },
    "Hermit Druid"            => { "dec 2003" => "banned" },
    "Hypergenesis"            => { "jun 2010" => "banned" },
    "Jace, the Mind Sculptor" => { "sep 2011" => "banned" },
    "Mental Misstep"          => { "sep 2011" => "banned" },
    "Metalworker"             => { "sep 2004" => "banned" },
    "Necropotence"            => { "mar 2001" => "banned" },
    "Oath of Druids"          => { "dec 2003" => "banned" },
    "Ponder"                  => { "sep 2011" => "banned" },
    "Preordain"               => { "sep 2011" => "banned" },
    "Replenish"               => { "mar 2001" => "banned" },
    "Sensei's Divining Top"   => { "sep 2008" => "banned" },
    "Skullclamp"              => { "sep 2004" => "banned" },
    "Stoneforge Mystic"       => { "sep 2011" => "banned" },
    "Survival of the Fittest" => { "mar 2001" => "banned" },
    "Sword of the Meek"       => { "jun 2010" => "banned" },
    "Tinker"                  => { "dec 2003" => "banned" },
  },

  ### INCOMPLETE
  # Suposedly march 1996 unrestricted "Sword of the Ages" in Vintage/Legacy, but I can't see any ban
  # Supposedly sep 1997 unrestricted "Mishra's Workshop", and "Zuran Orb" but I can't see any ban
  # Supposedly sep 1999 unbanned "Divine Intervention", no idea when it was banned
  # Supposedly sep 1999 unrestricted "Underworld Dreams", no idea when it was banned
  # There's huge deal of early history missing

  "legacy" => {
    # ante
    "Bronze Tablet"           => "banned",
    "Contract from Below"     => "banned",
    "Darkpact"                => "banned",
    "Demonic Attorney"        => "banned",
    "Jeweled Bird"            => "banned",
    "Timmerian Fiends"        => "banned",
    "Tempest Efreet"          => "banned",
    "Amulet of Quoz"          => "banned",
    "Rebirth"                 => "banned",
    # joke cards
    "Chaos Orb"               => "banned",
    "Falling Star"            => "banned",
    # actual cards

    "Strip Mine"              => { "sep 1996" => "banned" }, # wiki says it's standard ban, but it got b&r at some point, so guessing this
    "Ali from Cairo"          => { "start" => "banned", "mar 1996" => "legal" },
    "Ancestral Recall"        => { "start" => "banned" },
    "Balance"                 => { "apr 1995" => "banned" },
    "Bazaar of Baghdad"       => { "sep 2004" => "banned" },
    "Berserk"                 => { "start" => "banned", "mar 2003" => "legal" },
    "Black Lotus"             => { "start" => "banned" },
    "Black Vise"              => { "jan 1996" => "banned", "mar 1996" => "legal", "jun 1997" => "banned", "bfz" => "legal" },
    "Braingeyser"             => { "start" => "banned", "sep 2004" => "legal" },
    "Burning Wish"            => { "dec 2003" => "banned", "sep 2004" => "legal" },
    "Candelabra of Tawnos"    => { "may 1994" => "banned", "sep 1997" => "legal" },
    "Channel"                 => { "may 1994" => "banned" },
    "Chrome Mox"              => { "dec 2003" => "banned", "sep 2004" => "legal" },
    "Copy Artifact"           => { "may 1994" => "banned", "sep 1997" => "legal" },
    "Crop Rotation"           => { "sep 1999" => "banned", "sep 2004" => "legal" },
    "Demonic Consultation"    => { "sep 2000" => "banned" },
    "Demonic Tutor"           => { "may 1994" => "banned" },
    "Dig Through Time"        => { "start"=>"legal", "bfz"=>"banned"},
    "Dingus Egg"              => { "start" => "banned", "may 1994" => "legal" },
    "Doomsday"                => { "sep 1999" => "banned", "sep 2004" => "legal" },
    "Dream Halls"             => { "sep 1999"=>"banned", "sep 2009" => "legal"},
    "Earthcraft"              => { "mar 2003" => "banned" },
    "Enlightened Tutor"       => { "sep 1999" => "banned", "sep 2004" => "legal" },
    "Entomb"                  => { "mar 2003"=>"banned", "sep 2009" => "legal"},
    "Fact or Fiction"         => { "dec 2001" => "banned", "sep 2004" => "legal" },
    "Fastbond"                => { "sep 1996" => "banned" },
    "Feldon's Cane"           => { "may 1994" => "banned", "sep 1997" => "legal" },
    "Flash"                   => { "jun 2007" => "banned" },
    "Fork"                    => { "sep 2004" => "legal" },
    "Frantic Search"          => { "sep 1999" => "banned" },
    "Gauntlet of Might"       => { "start" => "banned", "may 1994" => "legal" },
    "Goblin Recruiter"        => { "sep 2004" => "banned" },
    "Grim Monolith"           => { "sep 1999" => "banned", "jun 2010" => "legal"},
    "Gush"                    => { "jun 2003" => "banned" },
    "Hermit Druid"            => { "sep 2004" => "banned" },
    "Hurkyl's Recall"         => { "sep 1999" => "banned", "mar 2003" => "legal" },
    "Icy Manipulator"         => { "start" => "banned", "may 1994" => "legal" },
    "Illusionary Mask"        => { "sep 2004" => "banned", "jun 2010" => "legal"},
    "Imperial Seal"           => { "sep 2005" => "banned" },
    "Ivory Tower"             => { "may 1994" => "banned", "sep 1999" => "legal" },
    "Land Tax"                => { "sep 2004"=>"banned", "jun 2012"=>"legal"},
    "Library of Alexandria"   => { "may 1994" => "banned" },
    "Lion's Eye Diamond"      => { "dec 2003" => "banned", "sep 2004" => "legal" },
    "Lotus Petal"             => { "sep 1999" => "banned", "sep 2004" => "legal" },
    "Mana Crypt"              => { "sep 1999" => "banned" },
    "Mana Drain"              => { "sep 2004" => "banned" },
    "Mana Vault"              => { "sep 1999" => "banned" },
    # "Maze of Ith"             => { "mar 1998" => "legal" },
    "Memory Jar"              => { "mar 1998" => "banned" },
    "Mental Misstep"          => { "sep 2011" => "banned"},
    "Metalworker"             => { "sep 2004"=>"banned", "sep 2009" => "legal"},
    "Mind Over Matter"        => { "sep 1999" => "banned", "jun 2007" => "legal"},
    "Mind Twist"              => { "jan 1996" => "banned" },
    "Mind's Desire"           => { "jun 2003" => "banned" },
    # "Mirror Universe"         => { "?" => "banned", "sep 1999" => "legal" },
    "Mishra's Workshop"       => { "sep 2004" => "banned" },
    "Mox Diamond"             => { "sep 1999" => "banned", "sep 2004" => "legal" },
    "Mox Emerald"             => { "start" => "banned" },
    "Mox Jet"                 => { "start" => "banned" },
    "Mox Pearl"               => { "start" => "banned" },
    "Mox Ruby"                => { "start" => "banned" },
    "Mox Sapphire"            => { "start" => "banned" },
    "Mystical Tutor"          => { "sep 1999" => "banned", "sep 2004" => "legal", "jun 2010" => "banned" },
    "Necropotence"            => { "sep 2000" => "banned" },
    "Oath of Druids"          => { "sep 2004" => "banned" },
    "Orcish Oriflamme"        => { "start" => "banned", "may 1994" => "legal" },
    # "Recall"                  => { "?" => "banned", "mar 2003" => "legal" },
    "Regrowth"                => { "may 1994" => "banned", "sep 2004" => "legal" },
    "Replenish"               => { "sep 2004" => "banned", "jun 2007" => "legal"},
    "Rukh Egg"                => { "start" => "banned", "may 1994" => "legal" },
    "Shahrazad"               => { "start" => "banned", "sep 1999" => "legal", "sep 2007" => "banned" },
    "Skullclamp"              => { "sep 2004" => "banned" },
    "Sol Ring"                => { "start" => "banned" },
    "Stroke of Genius"        => { "dec 1998" => "banned", "sep 2004" => "legal" },
    "Survival of the Fittest" => { "dec 2010" => "banned"},
    "Time Spiral"             => { "mar 1999"=>"banned", "dec 2010" => "legal"},
    "Timetwister"             => { "start" => "banned" },
    "Time Vault"              => { "start" => "banned", "mar 1996" => "legal", "sep 2008" => "banned" },
    "Time Walk"               => { "start" => "banned" },
    "Tinker"                  => { "sep 1999" => "banned" },
    "Tolarian Academy"        => { "dec 1998" => "banned" },
    "Treasure Cruise"         => { "frf"=> "banned"},
    "Vampiric Tutor"          => { "sep 1999" => "banned" },
    "Voltaic Key"             => { "sep 1999" => "banned", "sep 2004" => "legal" },
    "Wheel of Fortune"        => { "may 1994" => "banned" },
    "Windfall"                => { "dec 1998" => "banned" },
    "Worldgorger Dragon"      => { "sep 2004"=>"banned", "frf"=> "legal"},
    "Yawgmoth's Bargain"      => { "sep 1999" => "banned" },
    "Yawgmoth's Will"         => { "sep 1999" => "banned" },
  },
  "vintage" => {
    # ante
    "Bronze Tablet"           => "banned",
    "Contract from Below"     => "banned",
    "Darkpact"                => "banned",
    "Demonic Attorney"        => "banned",
    "Jeweled Bird"            => "banned",
    "Timmerian Fiends"        => "banned",
    "Tempest Efreet"          => "banned",
    "Amulet of Quoz"          => "banned",
    "Rebirth"                 => "banned",
    # joke cards
    "Chaos Orb"               => "banned",
    "Falling Star"            => "banned",
    # actual cards

    "Strip Mine"              => { "sep 1996" => "restricted" }, # wiki says it's standard ban, but it got b&r at some point, so guessing this
    "Ali from Cairo"          => { "start" => "restricted", "mar 1996" => "legal" },
    "Ancestral Recall"        => { "start" => "restricted" },
    "Balance"                 => { "apr 1995" => "restricted" },
    "Berserk"                 => { "start" => "restricted", "mar 2003" => "legal" },
    "Black Lotus"             => { "start" => "restricted" },
    "Black Vise"              => { "jan 1996" => "restricted", "mar 1996" => "legal", "jun 1997" => "restricted", "jun 2007" => "legal" },
    "Braingeyser"             => { "start" => "restricted", "sep 2004" => "legal" },
    "Brainstorm"              => { "jun 2008" => "restricted" },
    "Burning Wish"            => { "dec 2003" => "restricted", "sep 2012" => "legal" },
    "Candelabra of Tawnos"    => { "may 1994" => "restricted", "sep 1997" => "legal" },
    "Chalice of the Void"     => { "bfz"=>"restricted" },
    # Only reference I found is in unbanning
    # "Mind Twist and Channel When these cards were first banned in 1995,"
    # Mind Twist was actually banned January 1996, so yeah, making it so here too
    "Channel"                 => { "may 1994" => "restricted", "jan 1996" => "banned", "sep 2000" => "restricted" },
    "Chrome Mox"              => { "dec 2003" => "restricted", "sep 2008" => "legal" },
    "Copy Artifact"           => { "may 1994" => "restricted", "sep 1997" => "legal" },
    "Crop Rotation"           => { "sep 1999" => "restricted", "jun 2009" => "legal" },
    "Demonic Consultation"    => { "sep 2000" => "restricted" },
    "Demonic Tutor"           => { "may 1994" => "restricted" },
    "Dig Through Time"        => { "bfz"=>"restricted" },
    "Dingus Egg"              => { "start" => "restricted", "may 1994" => "legal" },
    "Doomsday"                => { "sep 1999" => "restricted", "sep 2004" => "legal" },
    "Dream Halls"             => { "sep 1999" => "restricted", "sep 2008" => "legal" },
    "Earthcraft"              => { "mar 2003" => "restricted", "sep 2004" => "legal" },
    "Enlightened Tutor"       => { "sep 1999" => "restricted", "jun 2009" => "legal" },
    "Entomb"                  => { "mar 2003" => "restricted", "jun 2009" => "legal" },
    "Fact or Fiction"         => { "dec 2001"=>"restricted", "sep 2011" => "legal" },
    "Fastbond"                => { "sep 1996" => "restricted" },
    "Feldon's Cane"           => { "may 1994" => "restricted", "sep 1997" => "legal" },
    "Flash"                   => { "jun 2008" => "restricted" },
    # "Fork"                    => { "?" => "restricted", "sep 2004" => "legal" },
    "Frantic Search"          => { "sep 1999" => "restricted", "sep 2010" => "legal" },
    "Gauntlet of Might"       => { "start" => "restricted", "may 1994" => "legal" },
    "Gifts Ungiven"           => { "jun 2007"=>"restricted", "frf"=> "legal" },
    "Grim Monolith"           => { "sep 1999" => "restricted", "jun 2009" => "legal" },
    "Gush"                    => { "jun 2003" => "restricted", "jun 2007" => "legal", "jun 2008" => "restricted", "sep 2010" => "legal" },
    "Hurkyl's Recall"         => { "sep 1999" => "restricted", "mar 2003" => "legal" },
    "Icy Manipulator"         => { "start" => "restricted", "may 1994" => "legal" },
    "Imperial Seal"           => { "sep 2005" => "restricted" },
    "Ivory Tower"             => { "may 1994" => "restricted", "sep 1999" => "legal" },
    "Library of Alexandria"   => { "may 1994" => "restricted" },
    "Lion's Eye Diamond"      => { "dec 2003" => "restricted" },
    "Lodestone Golem"         => {"soi" => "restricted"},
    "Lotus Petal"             => { "sep 1999" => "restricted" },
    "Mana Crypt"              => { "sep 1999" => "restricted" },
    "Mana Vault"              => { "sep 1999" => "restricted" },
    # "Maze of Ith"             => { "mar 1998" => "legal" },
    "Memory Jar"              => { "mar 1998" => "restricted" },
    "Merchant Scroll"         => { "jun 2008" => "restricted" },
    "Mind Over Matter"        => { "sep 1999" => "restricted", "sep 2005" => "legal" },
    "Mind Twist"              => { "jan 1996" => "banned", "sep 2000" => "restricted", "jun 2007" => "legal" },
    "Mind's Desire"           => { "jun 2003" => "restricted" },
    # "Mirror Universe"         => { "?" => "restricted", "sep 1999" => "legal" },
    "Mox Diamond"             => { "sep 1999" => "restricted", "sep 2008" => "legal" },
    "Mox Emerald"             => { "start" => "restricted" },
    "Mox Jet"                 => { "start" => "restricted" },
    "Mox Pearl"               => { "start" => "restricted" },
    "Mox Ruby"                => { "start" => "restricted" },
    "Mox Sapphire"            => { "start" => "restricted" },
    "Mystical Tutor"          => { "sep 1999" => "restricted" },
    "Necropotence"            => { "sep 2000" => "restricted" },
    "Orcish Oriflamme"        => { "start" => "restricted", "may 1994" => "legal" },
    "Personal Tutor"          => { "sep 2005" => "restricted", "sep 2008" => "legal" },
    "Ponder"                  => { "jun 2008" => "restricted" },
    # "Recall"                  => { "?" => "restricted", "mar 2003" => "legal" },
    "Regrowth"                => { "may 1994" => "restricted", "may 2013" => "legal" },
    "Rukh Egg"                => { "start" => "restricted", "may 1994" => "legal" },
    "Shahrazad"               => { "start" => "banned", "sep 1999" => "legal", "sep 2007" => "banned" },
    "Sol Ring"                => { "start" => "restricted" },
    "Stroke of Genius"        => { "dec 1998" => "restricted", "dec 2004" => "legal" },
    "Thirst for Knowledge"    => { "jun 2009"=>"restricted", "bfz"=>"legal" },
    "Time Spiral"             => { "mar 1999" => "restricted", "sep 2008" => "legal" },
    "Timetwister"             => { "start" => "restricted" },
    "Time Vault"              => { "start" => "restricted", "may 1994" => "banned", "mar 1996" => "legal", "sep 2008" => "restricted" },
    "Time Walk"               => { "start" => "restricted" },
    "Tinker"                  => { "sep 1999" => "restricted" },
    "Tolarian Academy"        => { "dec 1998" => "restricted" },
    "Treasure Cruise"         => { "frf"=> "restricted" },
    "Trinisphere"             => { "mar 2005" => "restricted" },
    "Vampiric Tutor"          => { "sep 1999" => "restricted" },
    "Voltaic Key"             => { "sep 1999" => "restricted", "jun 2007" => "legal" },
    "Wheel of Fortune"        => { "may 1994" => "restricted" },
    "Windfall"                => { "dec 1998" => "restricted" },
    "Yawgmoth's Bargain"      => { "sep 1999" => "restricted" },
    "Yawgmoth's Will"         => { "sep 1999" => "restricted" },
  },

  # http://www.duelcommander.com/banlist/
  "duel commander" => {
    "Ancestral Recall" => "banned",
    "Ancient Tomb" => "banned",
    "Back to Basics" => "banned",
    "Black Lotus" => "banned",
    "Channel" => "banned",
    "Chaos Orb" => "banned",
    "Dig Through Time" => "banned",
    "Entomb" => "banned",
    "Falling Star" => "banned",
    "Fastbond" => "banned",
    "Food Chain" => "banned",
    "Gaea's Cradle" => "banned",
    "Gifts Ungiven" => "banned",
    "Grim Monolith" => "banned",
    "Hermit Druid" => "banned",
    "Humility" => "banned",
    "Imperial Seal" => "banned",
    "Karakas" => "banned",
    "Library of Alexandria" => "banned",
    "Loyal Retainers" => "banned",
    "Mana Crypt" => "banned",
    "Mana Drain" => "banned",
    "Mana Vault" => "banned",
    "Mind Twist" => "banned",
    "Mishra's Workshop" => "banned",
    "Mox Emerald" => "banned",
    "Mox Jet" => "banned",
    "Mox Pearl" => "banned",
    "Mox Ruby" => "banned",
    "Mox Sapphire" => "banned",
    "Mystical Tutor" => "banned",
    "Natural Order" => "banned",
    "Necrotic Ooze" => "banned",
    "Oath of Druids" => "banned",
    "Protean Hulk" => "banned",
    "Sensei's Divining Top" => "banned",
    "Shahrazad" => "banned",
    "Sol Ring" => "banned",
    "Strip Mine" => "banned",
    "The Tabernacle at Pendrell Vale" => "banned",
    "Time Vault" => "banned",
    "Time Walk" => "banned",
    "Tinker" => "banned",
    "Tolarian Academy" => "banned",
    "Treasure Cruise" => "banned",
    "Vampiric Tutor" => "banned",
    "Derevi, Empyrial Tactician" => "restricted",
    "Edric, Spymaster of Trest" => "restricted",
    "Erayo, Soratami Ascendant" => "restricted",
    "Marath, Will of the Wild" => "restricted",
    "Oloro, Ageless Ascetic" => "restricted",
    "Rofellos, Llanowar Emissary" => "restricted",
    "Tasigur, the Golden Fang" => "restricted",
    "Yisan, the Wanderer Bard" => "restricted",
    "Zur the Enchanter" => "restricted",
  }
}

class BanList
  attr_reader :dates, :bans
  def initialize
    @dates = Hash[BanListChangeDates.map{|key, date| [key, Date.parse(date)]}]
    @bans = Hash[DynamicBanListData.map do |format, changes|
      [format, parse_changes(changes)]
    end]
  end

  # Response is: "banned", "restricted", nil
  # nil could mean legal or not depending on printing
  # It's not this class's business to decide that
  def legality(format, card_name, time)
    legality = @bans.fetch(format, {}).fetch(card_name, {})
    status = "legal"
    legality.each do |change_time,leg|
      break if time and change_time > time
      status = leg
    end
    status
  end

  def full_ban_list(format, time)
    result = {}
    @bans.fetch(format, {}).keys.each do |card_name|
      status = legality(format, card_name, time)
      result[card_name] = status unless status == "legal"
    end
    result
  end

  private

  def parse_changes(changes)
    seen_warns = Set[]
    Hash[changes.map{|card, legalities|
      legalities = {"start" => legalities} unless legalities.is_a?(Hash)
      legalities = legalities.map{|dat, leg|
        unless @dates[dat]
          warn "Unknown date: #{dat}" unless seen_warns.include?(dat)
          seen_warns << dat
          next
        end # temporary until this list is finished
        [@dates[dat], leg]
      }.compact
      [card, legalities]
    }]
  end

  # BanList is singleton
  def self.new
    @instance ||= super
  end
end

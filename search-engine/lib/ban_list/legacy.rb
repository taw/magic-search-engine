BanList.for_format("legacy") do
  format_start(
    nil,
    "Ali from Cairo" => "banned",
    "Amulet of Quoz" => "banned",
    "Ancestral Recall" => "banned",
    "Berserk" => "banned",
    "Black Lotus" => "banned",
    "Braingeyser" => "banned",
    "Bronze Tablet" => "banned",
    "Chaos Orb" => "banned",
    "Contract from Below" => "banned",
    "Darkpact" => "banned",
    "Demonic Attorney" => "banned",
    "Dingus Egg" => "banned",
    "Falling Star" => "banned",
    "Gauntlet of Might" => "banned",
    "Icy Manipulator" => "banned",
    "Jeweled Bird" => "banned",
    "Mox Emerald" => "banned",
    "Mox Jet" => "banned",
    "Mox Pearl" => "banned",
    "Mox Ruby" => "banned",
    "Mox Sapphire" => "banned",
    "Orcish Oriflamme" => "banned",
    "Rebirth" => "banned",
    "Rukh Egg" => "banned",
    "Shahrazad" => "banned",
    "Sol Ring" => "banned",
    "Tempest Efreet" => "banned",
    "Time Vault" => "banned",
    "Time Walk" => "banned",
    "Timetwister" => "banned",
    "Timmerian Fiends" => "banned",
    # Type 1.5 banned everything on either Type 1 list - DCI Universal Tournament Rules
    # section 2.5.1, https://web.archive.org/web/19961219095847/http://www.wizards.com/DCI/Unirules.html
    # - so these mirror Vintage's initial list. The Type 1 lists themselves are printed in
    # The Duelist #10 (May 1996), https://archive.org/details/duelist-10
    "Divine Intervention" => "banned",
    "Maze of Ith" => "banned",
    "Mirror Universe" => "banned",
    "Mishra's Workshop" => "banned",
    "Sword of the Ages" => "banned",
    "Underworld Dreams" => "banned",
    "Zuran Orb" => "banned",
  )

  change(
    "1994-05-02",
    nil,
    "Candelabra of Tawnos" => "banned",
    "Channel" => "banned",
    "Copy Artifact" => "banned",
    "Demonic Tutor" => "banned",
    "Feldon's Cane" => "banned",
    "Ivory Tower" => "banned",
    "Library of Alexandria" => "banned",
    "Regrowth" => "banned",
    "Wheel of Fortune" => "banned",
    "Dingus Egg" => "legal",
    "Gauntlet of Might" => "legal",
    "Icy Manipulator" => "legal",
    "Orcish Oriflamme" => "legal",
    "Rukh Egg" => "legal",
    "Recall" => "banned",
    "Fork" => "banned",
  )

  change(
    "1995-05-01",
    nil,
    "Balance" => "banned",
  )

  change(
    "1996-02-01",
    nil,
    "Black Vise" => "banned",
    "Mind Twist" => "banned",
  )

  change(
    "1996-04-01",
    "https://web.archive.org/web/19960510142729/http://www.wizards.com/DCI/ban_rest_letter.html",
    "Ali from Cairo" => "legal",
    "Black Vise" => "legal",
    "Sword of the Ages" => "legal",
    "Time Vault" => "legal",
  )

  change(
    "1996-10-01",
    nil,
    "Fastbond" => "banned",
  )

  change(
    "1997-07-01",
    nil,
    "Black Vise" => "banned",
  )

  # Mirrors Vintage. The DCI's printed Type 1.5 list did not catch up until 1999-01-01
  # (Feldon's Cane) and 1999-04-01 (Candelabra of Tawnos, Copy Artifact, Mishra's Workshop),
  # but Type 1.5 was *defined* as "any card appearing on either the Banned or Restricted
  # Lists for Standard (Type II) or Classic (Type I) tournaments", so those announcements
  # are the printed list catching up to the rule rather than the rule changing. Keeping
  # Vintage's dates is also what banlist_spec's legacy_was_just_vintage_plus_before_split
  # asserts.
  change(
    "1997-10-01",
    nil,
    "Candelabra of Tawnos" => "legal",
    "Copy Artifact" => "legal",
    "Feldon's Cane" => "legal",
    "Mishra's Workshop" => "legal",
    "Zuran Orb" => "legal",
  )

  change(
    "1998-01-01",
    "https://web.archive.org/web/19990203122929/http://www.wizards.com/DCI/BRAnnouncement.html",
    "Strip Mine" => "banned",
  )

  change(
    "1999-01-01",
    "https://web.archive.org/web/19990209004446/http://www.wizards.com/DCI/MTG_DCI_BR12-1-98.html",
    "Stroke of Genius" => "banned",
    "Tolarian Academy" => "banned",
    "Windfall" => "banned",
  )

  # Emergency announcement. Its page was already a 404 when the Wayback Machine first
  # visited, so only the date survives, from the DCI announcement archive index.
  change(
    "1999-03-11",
    "https://web.archive.org/web/20010128184200/http://www.wizards.com/DCI/announce_archive.asp",
    "Memory Jar" => "banned",
  )

  change(
    "1999-04-01",
    "https://web.archive.org/web/19990506144254/http://www.wizards.com/DCI/MTG_DCI_BR2-26-99.html",
    "Maze of Ith" => "legal",
    "Time Spiral" => "banned",
  )

  change(
    "1999-10-01",
    "https://web.archive.org/web/20000305053359/http://www.wizards.com/DCI/announce.asp?dci19990901b",
    "Crop Rotation" => "banned",
    "Doomsday" => "banned",
    "Dream Halls" => "banned",
    "Enlightened Tutor" => "banned",
    "Frantic Search" => "banned",
    "Grim Monolith" => "banned",
    "Hurkyl's Recall" => "banned",
    "Lotus Petal" => "banned",
    "Mana Crypt" => "banned",
    "Mana Vault" => "banned",
    "Mind Over Matter" => "banned",
    "Mox Diamond" => "banned",
    "Mystical Tutor" => "banned",
    "Tinker" => "banned",
    "Vampiric Tutor" => "banned",
    "Voltaic Key" => "banned",
    "Yawgmoth's Bargain" => "banned",
    "Yawgmoth's Will" => "banned",
    "Divine Intervention" => "legal",
    "Ivory Tower" => "legal",
    "Mirror Universe" => "legal",
    "Shahrazad" => "legal",
    "Underworld Dreams" => "legal",
  )

  change(
    "2000-10-01",
    nil,
    "Demonic Consultation" => "banned",
    "Necropotence" => "banned",
  )

  change(
    "2002-01-01",
    "http://web.archive.org/web/20111121212710/http://crystalkeep.com/magic/rules/dci/update-011201.txt",
    "Fact or Fiction" => "banned",
  )

  change(
    "2003-04-01",
    "http://www.wizards.com/dci/main.asp?x=Banned_Restricted_List_0303",
    "Earthcraft" => "banned",
    "Entomb" => "banned",
    "Berserk" => "legal",
    "Hurkyl's Recall" => "legal",
    "Recall" => "legal",
  )

  change(
    "2003-07-01",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20030529a",
    "Gush" => "banned",
    "Mind's Desire" => "banned",
  )

  change(
    "2004-01-01",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20031201a",
    "Burning Wish" => "banned",
    "Chrome Mox" => "banned",
    "Lion's Eye Diamond" => "banned",
  )

  change(
    "2004-09-20",
    "http://www.wizards.com/Default.asp?x=dci/announce/dci20040901a",
    "Bazaar of Baghdad" => "banned",
    "Goblin Recruiter" => "banned",
    "Hermit Druid" => "banned",
    "Illusionary Mask" => "banned",
    "Land Tax" => "banned",
    "Mana Drain" => "banned",
    "Metalworker" => "banned",
    "Mishra's Workshop" => "banned",
    "Oath of Druids" => "banned",
    "Replenish" => "banned",
    "Skullclamp" => "banned",
    "Worldgorger Dragon" => "banned",
    "Braingeyser" => "legal",
    "Burning Wish" => "legal",
    "Chrome Mox" => "legal",
    "Crop Rotation" => "legal",
    "Doomsday" => "legal",
    "Enlightened Tutor" => "legal",
    "Fact or Fiction" => "legal",
    "Fork" => "legal",
    "Lion's Eye Diamond" => "legal",
    "Lotus Petal" => "legal",
    "Mox Diamond" => "legal",
    "Mystical Tutor" => "legal",
    "Regrowth" => "legal",
    "Stroke of Genius" => "legal",
    "Voltaic Key" => "legal",
  )

  change(
    "2005-09-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20050901a",
    "Imperial Seal" => "banned",
  )

  change(
    "2007-06-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20070601a",
    "Flash" => "banned",
    "Mind Over Matter" => "legal",
    "Replenish" => "legal",
  )

  change(
    "2007-09-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20070901a",
    "Shahrazad" => "banned",
  )

  change(
    "2008-09-20",
    "https://magic.wizards.com/en/articles/archive/feature/september-1-2008-dci-banned-and-restricted-list-announcement-2008-09-01",
    "Time Vault" => "banned",
  )

  change(
    "2009-10-01",
    "https://magic.wizards.com/en/articles/archive/feature/september-18-2009-dci-banned-restricted-list-announcement-2009-09-18",
    "Dream Halls" => "legal",
    "Entomb" => "legal",
    "Metalworker" => "legal",
  )

  change(
    "2010-07-01",
    "https://magic.wizards.com/en/articles/archive/magic-online/june-18-2010-dci-banned-restricted-list-announcement-2010-06-18",
    "Mystical Tutor" => "banned",
    "Grim Monolith" => "legal",
    "Illusionary Mask" => "legal",
  )

  change(
    "2011-01-01",
    "https://magic.wizards.com/en/articles/archive/feature/december-20-2010-dci-banned-restricted-list-announcement-2010-12-20",
    "Survival of the Fittest" => "banned",
    "Time Spiral" => "legal",
  )

  change(
    "2011-10-01",
    "https://magic.wizards.com/en/articles/archive/feature/september-20-2011-dci-banned-restricted-list-announcement-2011-09-20",
    "Mental Misstep" => "banned",
  )

  change(
    "2012-06-29",
    "https://magic.wizards.com/en/articles/archive/feature/june-20-2012-dci-banned-restricted-list-announcement-2012-06-20",
    "Land Tax" => "legal",
  )

  change(
    "2015-01-23",
    "https://magic.wizards.com/en/articles/archive/feature/banned-and-restricted-announcement-2015-01-19",
    "Treasure Cruise" => "banned",
    "Worldgorger Dragon" => "legal",
  )

  change(
    "2015-10-02",
    "https://magic.wizards.com/en/articles/archive/news/september-28-2015-banned-and-restricted-announcement-2015-09-28",
    "Dig Through Time" => "banned",
    "Black Vise" => "legal",
  )

  change(
    "2017-04-24",
    "https://magic.wizards.com/en/articles/archive/news/april-24-2017-banned-and-restricted-announcement-2017-04-24",
    "Sensei's Divining Top" => "banned",
  )

  change(
    "2018-07-06",
    "https://magic.wizards.com/en/articles/archive/news/july-2-2018-banned-and-restricted-update-2018-07-02",
    "Gitaxian Probe" => "banned",
    "Deathrite Shaman" => "banned",
  )

  change(
    "2019-11-18",
    "https://magic.wizards.com/en/articles/archive/news/november-18-2019-banned-and-restricted-announcement",
    "Wrenn and Six" => "banned",
  )

  change(
    "2020-03-10",
    "https://magic.wizards.com/en/articles/archive/news/march-9-2020-banned-and-restricted-announcement",
    "Underworld Breach" => "banned",
  )

  change(
    "2020-05-18",
    "https://magic.wizards.com/en/articles/archive/news/may-18-2020-banned-and-restricted-announcement",
    "Lurrus of the Dream-Den" => "banned",
    "Zirda, the Dawnwaker" => "banned",
  )

  change(
    "2020-06-10",
    "https://magic.wizards.com/en/articles/archive/news/depictions-racism-magic-2020-06-10",
    "Cleanse" => "banned",
    "Crusade" => "banned",
    "Imprison" => "banned",
    "Invoke Prejudice" => "banned",
    "Jihad" => "banned",
    "Pradesh Gypsies" => "banned",
    "Stone-Throwing Devils" => "banned",
  )

  change(
    "2021-02-15",
    "https://magic.wizards.com/en/articles/archive/news/february-15-2021-banned-and-restricted-announcement",
    "Arcum's Astrolabe" => "banned",
    "Dreadhorde Arcanist" => "banned",
    "Oko, Thief of Crowns" => "banned",
  )

  change(
    "2022-01-25",
    "https://magic.wizards.com/en/articles/archive/news/january-25-2022-banned-and-restricted-announcement",
    "Ragavan, Nimble Pilferer" => "banned",
  )

  change(
    "2023-03-06",
    "https://magic.wizards.com/en/news/announcements/march-6-2023-banned-and-restricted-announcement",
    "Expressive Iteration" => "banned",
    "White Plume Adventurer" => "banned",
  )

  change(
    "2023-08-07",
    "https://magic.wizards.com/en/news/announcements/august-7-2023-banned-and-restricted-announcement",
    "Mind's Desire" => "legal",
  )

  change(
    "2024-05-13",
    "https://magic.wizards.com/en/news/announcements/may-13-2024-banned-and-restricted-announcement",
    # All Sticker Cards, as per linked url
    "Aerialephant" => "banned",
    "Ambassador Blorpityblorpboop" => "banned",
    "Baaallerina" => "banned",
    "_____ Balls of Fire" => "banned",
    "Bioluminary" => "banned",
    "_____ Bird Gets the Worm" => "banned",
    "Carnival Carnivore" => "banned",
    "Chicken Troupe" => "banned",
    "Clandestine Chameleon" => "banned",
    "Command Performance" => "banned",
    "Done for the Day" => "banned",
    "Fight the _____ Fight" => "banned",
    "Finishing Move" => "banned",
    "Glitterflitter" => "banned",
    "_____ Goblin" => "banned",
    '"Name Sticker" Goblin' => "banned", # not explicitly, it's just MTGO variant
    "Last Voyage of the _____" => "banned",
    "Lineprancers" => "banned",
    "Make a _____ Splash" => "banned",
    "Minotaur de Force" => "banned",
    "_____-o-saurus" => "banned",
    "Park Bleater" => "banned",
    "Pin Collection" => "banned",
    "Prize Wall" => "banned",
    "Proficient Pyrodancer" => "banned",
    "Robo-Piñata" => "banned",
    "_____ _____ Rocketship" => "banned",
    "Roxi, Publicist to the Stars" => "banned",
    "Scampire" => "banned",
    "Stiltstrider" => "banned",
    "Sword-Swallowing Seraph" => "banned",
    "Ticketomaton" => "banned",
    "_____ _____ _____ Trespasser" => "banned",
    "Tusk and Whiskers" => "banned",
    "Wicker Picker" => "banned",
    "Wizards of the _____" => "banned",
    "Wolf in _____ Clothing" => "banned",
    # All Attraction Cards, as per linked url
    "Coming Attraction" => "banned",
    "Complaints Clerk" => "banned",
    "Deadbeat Attendant" => "banned",
    "Dee Kay, Finder of the Lost" => "banned",
    "Discourtesy Clerk" => "banned",
    "Draconian Gate-Bot" => "banned",
    "\"Lifetime\" Pass Holder" => "banned",
    "Line Cutter" => "banned",
    "Monitor Monitor" => "banned",
    "Myra the Magnificent" => "banned",
    "Petting Zookeeper" => "banned",
    "Quick Fixer" => "banned",
    "Rad Rascal" => "banned",
    "Ride Guide" => "banned",
    "Seasoned Buttoneer" => "banned",
    "Soul Swindler" => "banned",
    "Spinnerette, Arachnobat" => "banned",
    "Squirrel Squatters" => "banned",
    "Step Right Up" => "banned",
    "The Most Dangerous Gamer" => "banned",
    # t:attraction
    "Balloon Stand" => "banned",
    "Bounce Chamber" => "banned",
    "Bumper Cars" => "banned",
    "Centrifuge" => "banned",
    "Clown Extruder" => "banned",
    "Concession Stand" => "banned",
    "Costume Shop" => "banned",
    "Cover the Spot" => "banned",
    "Dart Throw" => "banned",
    "Drop Tower" => "banned",
    "Ferris Wheel" => "banned",
    "Foam Weapons Kiosk" => "banned",
    "Fortune Teller" => "banned",
    "Gallery of Legends" => "banned",
    "Gift Shop" => "banned",
    "Guess Your Fate" => "banned",
    "Hall of Mirrors" => "banned",
    "Haunted House" => "banned",
    "Information Booth" => "banned",
    "Kiddie Coaster" => "banned",
    "Log Flume" => "banned",
    "Memory Test" => "banned",
    "Merry-Go-Round" => "banned",
    "Pick-a-Beeble" => "banned",
    "Push Your Luck" => "banned",
    "Roller Coaster" => "banned",
    "Scavenger Hunt (a)" => "banned",
    "Scavenger Hunt (b)" => "banned",
    "Scavenger Hunt (c)" => "banned",
    "Scavenger Hunt (d)" => "banned",
    "Scavenger Hunt (e)" => "banned",
    "Scavenger Hunt (f)" => "banned",
    "Spinny Ride" => "banned",
    "Squirrel Stack" => "banned",
    "Storybook Ride" => "banned",
    "Swinging Ship" => "banned",
    "The Superlatorium (a)" => "banned",
    "The Superlatorium (b)" => "banned",
    "The Superlatorium (c)" => "banned",
    "The Superlatorium (d)" => "banned",
    "The Superlatorium (e)" => "banned",
    "The Superlatorium (f)" => "banned",
    "Trash Bin" => "banned",
    "Trivia Contest (a)" => "banned",
    "Trivia Contest (b)" => "banned",
    "Trivia Contest (c)" => "banned",
    "Trivia Contest (d)" => "banned",
    "Trivia Contest (e)" => "banned",
    "Trivia Contest (f)" => "banned",
    "Tunnel of Love" => "banned",
    # t:stickers
    "Ancestral Hot Dog Minotaur" => "banned",
    "Carnival Elephant Meteor" => "banned",
    "Contortionist Otter Storm" => "banned",
    "Cool Fluffy Loxodon" => "banned",
    "Cursed Firebreathing Yogurt" => "banned",
    "Deep-Fried Plague Myr" => "banned",
    "Demonic Tourist Laser" => "banned",
    "Eldrazi Guacamole Tightrope" => "banned",
    "Elemental Time Flamingo" => "banned",
    "Eternal Acrobat Toast" => "banned",
    "Familiar Beeble Mascot" => "banned",
    "Geek Lotus Warrior" => "banned",
    "Giant Mana Cake" => "banned",
    "Goblin Coward Parade" => "banned",
    "Happy Dead Squirrel" => "banned",
    "Jetpack Death Seltzer" => "banned",
    "Misunderstood Trapeze Elf" => "banned",
    "Mystic Doom Sandwich" => "banned",
    "Narrow-Minded Baloney Fireworks" => "banned",
    "Night Brushwagg Ringmaster" => "banned",
    "Notorious Sliver War" => "banned",
    "Phyrexian Midway Bamboozle" => "banned",
    "Playable Delusionary Hydra" => "banned",
    "Primal Elder Kitty" => "banned",
    "Sassy Gremlin Blood" => "banned",
    "Slimy Burrito Illusion" => "banned",
    "Snazzy Aether Homunculus" => "banned",
    "Space Fungus Snickerdoodle" => "banned",
    "Spooky Clown Mox" => "banned",
    "Squid Fire Knight" => "banned",
    "Squishy Sphinx Ninja" => "banned",
    "Sticky Kavu Daredevil" => "banned",
    "Trained Blessed Mind" => "banned",
    "Trendy Circus Pirate" => "banned",
    "Unassuming Gelatinous Serpent" => "banned",
    "Unglued Pea-Brained Dinosaur" => "banned",
    "Unhinged Beast Hunt" => "banned",
    "Unique Charmed Pants" => "banned",
    "Unsanctioned Ancient Juggler" => "banned",
    "Unstable Robot Dragon" => "banned",
    "Urza's Dark Cannonball" => "banned",
    "Vampire Champion Fury" => "banned",
    "Weird Angel Flame" => "banned",
    "Werewolf Lightning Mage" => "banned",
    "Wild Ogre Bupkis" => "banned",
    "Wrinkly Monkey Shenanigans" => "banned",
    "Yawgmoth Merfolk Soul" => "banned",
    "Zombie Cheese Magician" => "banned",
  )

  change(
    "2024-08-26",
    "https://magic.wizards.com/en/news/announcements/august-26-2024-banned-and-restricted-announcement",
    "Grief" => "banned",
  )

  change(
    "2024-12-16",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-december-16-2024",
    "Psychic Frog" => "banned",
    "Vexing Bauble" => "banned",
  )

  change(
    "2025-03-24",
    "New sticker card printed and falls under sticker card ban",
    "Sticker sheet" => "banned",
  )

  change(
    "2025-03-31",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-announcement-march-31-2025",
    "Sowing Mycospawn" => "banned",
    "Troll of Khazad-dûm" => "banned",
  )

  change(
    "2025-11-10",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-november-10-2025",
    "Entomb" => "banned",
    "Nadu, Winged Wisdom" => "banned",
  )

  change(
    "2026-05-18",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-may-18-2026",
    "Undercity Informer" => "banned",
  )

  change(
    "2026-06-29",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-june-29-2026",
    "Candelabra of Tawnos" => "banned",
  )

  change(
    "2026-08-10",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-august-10-2026",
    "The Fantasticar" => "banned",
  )
end

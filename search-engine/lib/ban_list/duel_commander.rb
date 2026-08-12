# The committee split in late 2025, and there are now two sites:
#
# * https://www.duelcommander.org/ is the one that keeps running the format.
#   Its /announcements/archives/ only re-hosts 41 of the ~70 old announcements,
#   and those pages are abridged rewrites which silently drop unbans - the
#   2017-07 page lists 2 of that announcement's 8 changes, the 2015-03 page
#   lists the 3 bans but none of the 4 unbans, and so on. They're not usable
#   as a source, so we don't link them for anything historic.
# * https://www.mtgdc.info/ is the old site. It pivoted away from Magic, but it
#   still serves the verbatim originals of every announcement from 2015 up to
#   2025-09-29, so that's what we link to for those. It may well disappear
#   eventually. It threw away everything before 2015; those links go to
#   web.archive.org copies of the original duelcommander.com posts instead.
#
# From 2025-11-24 on the two sites publish *different* banlists (mtgdc.info's
# 2025-11-24 is a completely different announcement with 15 unbans). We follow
# duelcommander.org, and its current banlist page matches what this file says.
#
# Every state between 2012-04 and 2016-12 has been checked card by card against
# archived snapshots of the format's own banlist page.

BanList.for_format("duel commander") do
  format_start(
    "https://web.archive.org/web/20120610063711/http://duelcommander.com/2012/03/march-20th-banlist-update/",
    "Amulet of Quoz" => "banned",
    "Ancestral Recall" => "banned",
    "Back to Basics" => "banned",
    "Bitterblossom" => "banned",
    "Black Lotus" => "banned",
    "Bronze Tablet" => "banned",
    "Channel" => "banned",
    "Chaos Orb" => "banned",
    "Contract from Below" => "banned",
    "Crucible of Worlds" => "banned",
    "Darkpact" => "banned",
    "Demonic Attorney" => "banned",
    "Falling Star" => "banned",
    "Fastbond" => "banned",
    "Gifts Ungiven" => "banned",
    "Hermit Druid" => "banned",
    "Imperial Seal" => "banned",
    "Intuition" => "banned",
    "Jeweled Bird" => "banned",
    "Karakas" => "banned",
    "Library of Alexandria" => "banned",
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
    "Protean Hulk" => "banned",
    "Rebirth" => "banned",
    "Recurring Nightmare" => "banned",
    "Sensei's Divining Top" => "banned",
    "Shahrazad" => "banned",
    "Sol Ring" => "banned",
    "Staff of Domination" => "banned",
    "Strip Mine" => "banned",
    "Tempest Efreet" => "banned",
    "The Tabernacle at Pendrell Vale" => "banned",
    "Time Vault" => "banned",
    "Time Walk" => "banned",
    "Timmerian Fiends" => "banned",
    "Tinker" => "banned",
    "Tolarian Academy" => "banned",
    "Vampiric Tutor" => "banned",
    "Braids, Cabal Minion" => "banned_as_commander",
    "Erayo, Soratami Ascendant" => "banned_as_commander",
    "Rofellos, Llanowar Emissary" => "banned_as_commander",
    "Yawgmoth's Bargain" => "banned",
    "Serra Ascendant" => "banned",
    "Grindstone" => "banned",
    "Necropotence" => "banned",
    "Balance" => "banned",
  )

  # This is where the history starts. Before the 2012-03-20 announcement Duel
  # Commander had no ban list of its own - it was "the multiplayer Commander ban
  # list, plus these extras", so it can't be expressed here. That announcement cut
  # it loose and published the standalone list above.
  #
  # mtgdc.info archived away everything before 2015, but web.archive.org has the
  # originals on duelcommander.com, along with snapshots of the list itself to
  # check any state against - on /rules/ until 2013-08, on /banlist/ after that.

  change(
    "2012-07-01",
    "https://web.archive.org/web/20121127000448/http://duelcommander.com/2012/06/june-20th-banlist-update/",
    "Intuition" => "legal",
    "Recurring Nightmare" => "legal",
  )

  change(
    "2012-10-01",
    "https://web.archive.org/web/20121121164825/http://duelcommander.com/2012/09/septembre-20th-banlist-update/",
    "Ancient Tomb" => "banned",
    "Fastbond" => "legal",
    "Edric, Spymaster of Trest" => "banned_as_commander",
  )

  # The 2013-01 announcement changed no cards.

  change(
    "2013-05-03",
    "https://web.archive.org/web/20130904030307/http://duelcommander.com/2013/04/dragons-maze-banlist-update/",
    "Humility" => "banned",
    "Vanishing" => "banned",
    "Bitterblossom" => "legal",
    "Protean Hulk" => "legal",
    "Staff of Domination" => "legal",
  )

  change(
    "2013-07-19",
    "https://web.archive.org/web/20140208083634/http://duelcommander.com/2013/07/magic-2014-banlist-update-2/",
    "Protean Hulk" => "banned",
    "Winter Orb" => "banned",
  )

  change(
    "2013-09-27",
    "https://web.archive.org/web/20140208090637/http://duelcommander.com/2013/09/theros-banlist-update/",
    "Loyal Retainers" => "banned",
  )

  # The 2013-10-28 Commander 2013 announcement changed no cards.

  change(
    "2014-02-07",
    "https://web.archive.org/web/20140208081012/http://duelcommander.com/2014/01/born-gods-banlist-update/",
    "Grim Monolith" => "banned",
    "Natural Order" => "banned",
    "Oath of Druids" => "banned",
    "Vanishing" => "legal",
    "Derevi, Empyrial Tactician" => "banned_as_commander",
    "Zur the Enchanter" => "banned_as_commander",
  )

  # The 2014-04-28 (Journey into Nyx), 2014-06-09 (Conspiracy), 2014-09-22 (Khans
  # of Tarkir), 2014-11-03 (Commander 2014) and 2015-01-19 (Fate Reforged)
  # announcements all changed no cards.

  change(
    "2014-07-18",
    "https://web.archive.org/web/20150211133253/http://duelcommander.com/2014/07/magic-2015-banlist-update/",
    "Cataclysm" => "banned",
    "Oloro, Ageless Ascetic" => "banned_as_commander",
  )

  change(
    "2015-03-23",
    "https://www.mtgdc.info/announcements/2015/march-2015-rules-bannedrestricted-update",
    "Entomb" => "banned",
    "Fastbond" => "banned",
    "Food Chain" => "banned",
    "Braids, Cabal Minion" => "legal",
    "Crucible of Worlds" => "legal",
    "Sensei's Divining Top" => "legal",
    "Winter Orb" => "legal",
  )

  change(
    "2015-07-17",
    "https://www.mtgdc.info/announcements/2015/july-2015-rules-bannedrestricted-update",
    "Mystical Tutor" => "banned",
  )

  change(
    "2015-10-02",
    "https://www.mtgdc.info/announcements/2015/september-2015-rules-bannedrestricted-update",
    "Sensei's Divining Top" => "banned",
  )

  change(
    "2016-01-22",
    "https://www.mtgdc.info/announcements/2016/january-2016-rules-bannedrestricted-update",
    "Cataclysm" => "legal",
  )

  change(
    "2016-04-08",
    "https://www.mtgdc.info/announcements/2016/april-2016-rules-bannedrestricted-update",
    "Gaea's Cradle" => "banned",
    "Tasigur, the Golden Fang" => "banned_as_commander",
    "Yisan, the Wanderer Bard" => "banned_as_commander",
  )

  change(
    "2016-07-22",
    "https://www.mtgdc.info/announcements/2016/july-2016-rules-bannedrestricted-update",
    "Dig Through Time" => "banned",
    "Necrotic Ooze" => "banned",
    "Treasure Cruise" => "banned",
    "Marath, Will of the Wild" => "banned_as_commander",
  )

  # The 2016-09-26 announcement changed no cards, only the starting life total.
  # https://www.mtgdc.info/announcements/2016/september-2016-rules-bannedrestricted-update

  change(
    "2016-11-11",
    "https://www.mtgdc.info/announcements/2016/november-2016-rules-bannedrestricted-update",
    "Yawgmoth's Bargain" => "legal",
    "Serra Ascendant" => "legal",
    "Grindstone" => "legal",
    "Necropotence" => "legal",
    "Balance" => "legal",
  )

  change(
    "2017-04-21",
    "https://www.mtgdc.info/announcements/2017/april-2017-rules-bannedrestricted-update",
    "Chrome Mox" => "banned",
    "Mox Diamond" => "banned",
    "Yisan, the Wanderer Bard" => "legal",
    "Breya, Etherium Shaper" => "banned_as_commander",
    "Vial Smasher the Fierce" => "banned_as_commander",
  )

  change(
    "2017-07-21",
    "https://www.mtgdc.info/announcements/2017/july-2017-rules-bannedrestricted-update",
    "Emrakul, the Aeons Torn" => "banned",
    "Polymorph" => "banned",
    "Ancient Tomb" => "legal",
    "Fastbond" => "legal",
    "Mind Twist" => "legal",
    "Bruse Tarl, Boorish Herder" => "banned_as_commander",
    "Geist of Saint Traft" => "banned_as_commander",
    "Jace, Vryn's Prodigy" => "banned_as_commander",
    # "Jace, Telepath Unbound" => "banned_as_commander", # DFC of previous, should it be listed explicitly?
  )

  change(
    "2017-09-29",
    "https://www.mtgdc.info/announcements/2017/september-2017-rules-bannedrestricted-update",
    "Eidolon of the Great Revel" => "banned",
    "Fireblast" => "banned",
    "Price of Progress" => "banned",
    "Sulfuric Vortex" => "banned",
    "Edgar Markov" => "banned_as_commander",
  )

  change(
    "2017-12-01",
    "https://www.mtgdc.info/announcements/2017/november-2017-rules-bannedrestricted-update",
    "Fastbond" => "banned",
  )

  change(
    "2018-06-01",
    "https://www.mtgdc.info/announcements/2018/may-2018-rules-bannedrestricted-update",
    "Zurgo Bellstriker" => "banned_as_commander",
  )

  change(
    "2019-03-01",
    "https://www.mtgdc.info/announcements/2019/february-2019-rules-bannedrestricted-update",
    "Prime Speaker Vannifar" => "banned_as_commander",
    "Baral, Chief of Compliance" => "banned_as_commander",
  )

  change(
    "2019-08-31",
    "https://www.mtgdc.info/announcements/2019/august-2019-rules-bannedrestricted-update",
    "Arahbo, Roar of the World" => "banned_as_commander",
    "Najeela, the Blade-Blossom" => "banned_as_commander",
    "Teferi, Temporal Archmage" => "banned_as_commander",
    "Urza, Lord High Artificer" => "banned_as_commander",
    "Yuriko, the Tiger's Shadow" => "banned_as_commander",
    "Timetwister" => "banned",
    "Edric, Spymaster of Trest" => "legal",
    "Erayo, Soratami Ascendant" => "legal",
    "Zur the Enchanter" => "legal",
  )

  change(
    "2019-11-29",
    "https://www.mtgdc.info/announcements/2019/november-2019-rules-bannedrestricted-update",
    "Emry, Lurker of the Loch" => "banned_as_commander", # was experimentally legal
    "Edric, Spymaster of Trest" => "banned_as_commander", # was experimentally legal
    # "Erayo, Soratami Ascendant" => "legal", # officially legal, was experimentally legal
    "Scapeshift" => "banned",
  )

  change(
    "2020-02-28",
    "https://www.mtgdc.info/announcements/2020/february-2020-rules-bannedrestricted-update",
    "Thassa's Oracle" => "banned",
    "Ancient Tomb" => "banned",
    "Mox Opal" => "banned",
    "Sulfuric Vortex" => "legal",
  )

  change(
    "2020-05-29",
    "https://www.mtgdc.info/announcements/2020/may-2020-rules-bannedrestricted-update",
    "Lutri, the Spellchaser" => "banned",
    "Deflecting Swat" => "banned",
    "Fierce Guardianship" => "banned",
    "High Tide" => "banned",
    "Capture of Jingzhou" => "banned",
    "Temporal Manipulation" => "banned",
    "Time Warp" => "banned",
    "Cavern of Souls" => "banned",
    "Field of the Dead" => "banned",
    "Wasteland" => "banned",
    "Lion's Eye Diamond" => "banned",
    "Gifts Ungiven" => "legal",
    "Jace, Vryn's Prodigy" => "legal",
  )

  change(
    "2020-06-10",
    "https://www.mtgdc.info/announcements/2020/duel-commander-policy-about-offensive-cards",
    "Cleanse" => "banned",
    "Crusade" => "banned",
    "Imprison" => "banned",
    "Invoke Prejudice" => "banned",
    "Jihad" => "banned",
    "Pradesh Gypsies" => "banned",
    "Stone-Throwing Devils" => "banned",
  )

  change(
    "2020-08-28",
    "https://www.mtgdc.info/announcements/2020/august-2020-rules-bannedrestricted-update",
    "Genesis Storm" => "banned",
  )

  change(
    "2020-12-04",
    "https://www.mtgdc.info/announcements/2020/november-2020-rules-bannedrestricted-update",
    "Akiri, Line-Slinger" => "banned_as_commander",
    "Omnath, Locus of Creation" => "banned_as_commander",
    "Thrasios, Triton Hero" => "banned_as_commander",
    "Tymna the Weaver" => "banned_as_commander",
    "Jeweled Lotus" => "banned",
    "Uro, Titan of Nature's Wrath" => "banned",
  )

  change(
    "2021-01-25",
    "https://www.mtgdc.info/announcements/2021/january-2021-rules-bannedrestricted-update",
    "Esior, Wardwing Familiar" => "banned_as_commander",
    "Jeska, Thrice Reborn" => "banned_as_commander",
    "Fireblast" => "legal",
  )

  change(
    "2021-03-29",
    "https://www.mtgdc.info/announcements/2021/march-2021-rules-bannedrestricted-update",
    "Ardenn, Intrepid Archaeologist" => "banned_as_commander",
    "Keleth, Sunmane Familiar" => "banned_as_commander",
    "Krark, the Thumbless" => "banned_as_commander",
    "Ludevic, Necro-Alchemist" => "banned_as_commander",
    "Reyhan, Last of the Abzan" => "banned_as_commander",
    "Rograkh, Son of Rohgahh" => "banned_as_commander",
  )

  change(
    "2021-07-26",
    "https://www.mtgdc.info/announcements/2021/july-2021-rules-bannedrestricted-update",
    "Inalla, Archmage Ritualist" => "banned_as_commander",
    "Ragavan, Nimble Pilferer" => "banned_as_commander",
    "Gifts Ungiven" => "banned",
  )

  change(
    "2021-09-27",
    "https://www.mtgdc.info/announcements/2021/september-2021-rules-bannedrestricted-update",
    "Maddening Hex" => "banned",
    "Asmoranomardicadaistinaculdacar" => "banned_as_commander",
    "Winota, Joiner of Forces" => "banned_as_commander",
  )

  change(
    "2022-01-31",
    "https://www.mtgdc.info/announcements/2022/january-2022-rules-bannedrestricted-update",
    "Kraum, Ludevic's Opus" => "banned_as_commander",
    "Livio, Oathsworn Sentinel" => "banned_as_commander",
    "Teferi, Temporal Archmage" => "legal",
    "Marath, Will of the Wild" => "legal",
  )

  change(
    "2022-02-28",
    "https://www.mtgdc.info/announcements/2022/february-2022-rules-bannedrestricted-update",
    "Bruse Tarl, Boorish Herder" => "legal",
    "Jeska, Thrice Reborn" => "legal",
    "Keleth, Sunmane Familiar" => "legal",
    "Kraum, Ludevic's Opus" => "legal",
    "Livio, Oathsworn Sentinel" => "legal",
    "Ludevic, Necro-Alchemist" => "legal",
    "Reyhan, Last of the Abzan" => "legal",
    "Rograkh, Son of Rohgahh" => "legal",
    "Tymna the Weaver" => "legal",
    "Yoshimaru, Ever Faithful" => "banned_as_commander",
  )

  change(
    "2022-05-30",
    "https://www.mtgdc.info/announcements/2022/may-2022-rules-bannedrestricted-update",
    "Shorikai, Genesis Engine" => "banned_as_commander",
    "Bazaar of Baghdad" => "banned",
    "Ragavan, Nimble Pilferer" => "banned",
    "Serra's Sanctum"  => "banned",
  )

  change(
    "2022-07-25",
    "https://www.mtgdc.info/announcements/2022/july-2022-rules-bannedrestricted-update",
    "Minsc & Boo, Timeless Heroes" => "banned_as_commander",
  )

  change(
    "2022-09-26",
    "https://www.mtgdc.info/announcements/2022/september-2022-rules-bannedrestricted-update",
    "Yoshimaru, Ever Faithful" => "legal",
  )

  change(
    "2023-03-27",
    "https://www.mtgdc.info/announcements/2023/march-2023-rules-bannedrestricted-update",
    "Trazyn the Infinite" => "banned",
  )

  change(
    "2023-05-29",
    "https://www.mtgdc.info/announcements/2023/may-2023-rules-bannedrestricted-update",
    "Dihada, Binder of Wills" => "banned_as_commander",
    "Comet, Stellar Pup" => "banned",
    "Hogaak, Arisen Necropolis" => "banned",
    "Mox Amber" => "banned",
  )

  change(
    "2023-07-31",
    "https://www.mtgdc.info/announcements/2023/july-2023-rules-bannedrestricted-update",
    "Deadly Rollick" => "banned",
    "Flawless Maneuver" => "banned",
    "The One Ring" => "banned",
    "Eidolon of the Great Revel" => "legal",
    "High Tide" => "legal",
  )

  change(
    "2023-11-27",
    "https://www.mtgdc.info/announcements/2023/november-2023-rules-bannedrestricted-update",
    "Lotus Petal" => "banned",
    "Rain of Filth" => "banned",
  )

  change(
    "2024-03-25",
    "https://www.mtgdc.info/announcements/2024/march-2024-rules-bannedrestricted-update",
    "Raffine, Scheming Seer" => "banned_as_commander",
  )

  change(
    "2024-05-27",
    "https://www.mtgdc.info/announcements/2024/may-2024-rules-bannedrestricted-update",
    "Eris, Roar of the Storm" => "banned_as_commander",
    # and all sticker and attraction cards, like with official formats ban in:
    # "https://magic.wizards.com/en/news/announcements/may-13-2024-banned-and-restricted-announcement",
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
    "2024-06-17",
    "https://www.mtgdc.info/announcements/2024/june-17-2024-announcementupdate",
    "Ajani, Nacatl Pariah" => "banned_as_commander",
    "Ajani, Nacatl Avenger" => "banned_as_commander", # back face, listed so both faces agree
    "Nadu, Winged Wisdom" => "banned_as_commander",
  )

  change(
    "2024-07-22",
    "https://www.mtgdc.info/announcements/2024/july-22-2024-announcementupdate",
    "Old Stickfingers" => "banned_as_commander",
    "Ardenn, Intrepid Archaeologist" => "legal",
    "Thrasios, Triton Hero" => "legal",
    "Polymorph" => "legal",
  )

  change(
    "2024-09-30",
    "https://www.mtgdc.info/announcements/2024/september-30-2024-announcementupdate",
    "Tamiyo, Inquisitive Student" => "banned_as_commander",
    "Tamiyo, Seasoned Scholar" => "banned_as_commander", # back face, listed so both faces agree
  )

  change(
    "2025-01-27",
    "https://www.mtgdc.info/announcements/2025/january-27-2025",
    "Ezio Auditore da Firenze" => "banned_as_commander",
    "Balance" => "banned",
    "Reanimate" => "banned",
    "White Plume Adventurer" => "banned",
    "Akiri, Line-Slinger" => "legal",
  )

  change(
    "2025-03-24",
    "New sticker card printed and falls under sticker card ban",
    "Sticker sheet" => "banned",
  )

  change(
    "2025-05-26",
    "https://www.mtgdc.info/announcements/2025/may-26-2025",
    "Invert Polarity" => "banned",
    "Zurgo Bellstriker" => "legal",
    "Hogaak, Arisen Necropolis" => "banned_as_commander",
  )

  change(
    "2025-07-28",
    "https://www.mtgdc.info/announcements/2025/july-28-2025",
    "Blood Moon" => "banned",
    "Dark Ritual" => "banned",
    "Force of Will" => "banned",
    "Underworld Breach" => "banned",
  )

  change(
    "2025-09-29",
    "https://www.mtgdc.info/announcements/2025/september-29-2025",
    "Asmoranomardicadaistinaculdacar" => "legal",
    "Baral, Chief of Compliance" => "legal",
    "Esior, Wardwing Familiar" => "legal",
    "Rofellos, Llanowar Emissary" => "legal",
    "Loyal Retainers" => "legal",
  )

  change(
    "2025-11-24",
    "https://www.duelcommander.org/announcements/2025/11/24/",
    "Nadu, Winged Wisdom" => "banned",
    "Breya, Etherium Shaper" => "legal",
  )

  change(
    "2026-01-26",
    "https://www.duelcommander.org/announcements/2026/01/26/",
    "Rograkh, Son of Rohgahh" => "banned_as_commander",
    "Tasigur, the Golden Fang" => "legal",
    "Trazyn the Infinite" => "legal",
    "Necrotic Ooze" => "legal",
  )

  change(
    "2026-03-30",
    "https://www.duelcommander.org/announcements/2026/03/30/",
    "Lutri, the Spellchaser" => "banned_as_companion",
  )

  change(
    "2026-05-25",
    "https://www.duelcommander.org/announcements/2026/05/25/",
    "Emry, Lurker of the Loch" => "legal",
    "Najeela, the Blade-Blossom" => "legal",
    "Winota, Joiner of Forces" => "legal",
  )

  change(
    "2026-07-27",
    "https://www.duelcommander.org/announcements/2026/07/27/",
    "Spider-Man 2099" => "banned_as_commander",
    "Lumra, Bellow of the Woods" => "banned_as_commander",
    "The Fantasticar" => "banned_as_commander",
  )
end

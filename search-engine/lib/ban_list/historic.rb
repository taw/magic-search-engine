# This banlist doesn't distinguish "suspended" from "banned"
# "conjurable" and "specialized" are technically not a B&R issue, they're cards which
# can't go into a deck at all. Format::RESTRICTED_STATUSES groups them with the
# other restricted-family statuses for restricted: and f: searches - see _LEGALITY.md

BanList.for_format("historic") do
  change(
    "2019-12-10",
    "https://magic.wizards.com/en/articles/archive/magic-digital/historic-suspension-announcement-2019-12-10",
    "Once Upon a Time" => "banned",
    "Field of the Dead" => "banned",
    "Veil of Summer" => "banned",
    "Oko, Thief of Crowns" => "banned",
  )

  change(
    "2020-03-10",
    "https://magic.wizards.com/en/articles/archive/news/march-9-2020-banned-and-restricted-announcement",
    "Field of the Dead" => "legal",
  )

  change(
    "2020-06-01",
    "https://magic.wizards.com/en/articles/archive/news/june-1-2020-banned-and-restricted-announcement",
    "Agent of Treachery" => "banned",
    "Fires of Invention" => "banned",
  )

  change(
    "2020-06-09",
    "https://magic.wizards.com/en/articles/archive/news/suspension-update-historic-digital-format-2020-06-08",
    "Winota, Joiner of Forces" => "banned", # "suspended"
  )

  change(
    "2020-07-13",
    "https://magic.wizards.com/en/articles/archive/news/july-13-2020-banned-and-restricted-announcement-2020-07-13",
    "Nexus of Fate" => "banned",
    "Burning-Tree Emissary" => "banned",
  )

  change(
    "2020-08-03",
    "https://magic.wizards.com/en/articles/archive/news/august-8-2020-banned-and-restricted-announcement",
    "Wilderness Reclamation" => "banned", # "suspended",
    "Teferi, Time Raveler" => "banned", # "suspended"
  )

  change(
    "2020-08-24",
    "https://magic.wizards.com/en/articles/archive/news/august-24-2020-banned-and-restricted-announcement",
    "Field of the Dead" => "banned",
  )

  change(
    "2020-10-12",
    "https://magic.wizards.com/en/articles/archive/news/october-12-2020-banned-and-restricted-announcement",
    "Omnath, Locus of Creation" => "banned", # "suspended"
    # "Teferi, Time Raveler" => "banned", # from "suspended"
    # "Wilderness Reclamation" => "banned", # from "suspended"
    "Burning-Tree Emissary" => "legal", # from unsuspended.
  )

  change(
    "2021-02-15",
    "https://magic.wizards.com/en/articles/archive/news/february-15-2021-banned-and-restricted-announcement",
    # "Omnath, Locus of Creation" => "banned", # from "suspended"
    "Uro, Titan of Nature's Wrath" => "banned",
  )

  # preemptively banned
  change(
    "2021-04-23",
    "https://twitter.com/MTG_Arena/status/1362555679844814853",
    "Swords to Plowshares" => "banned",
    "Counterspell" => "banned",
    "Dark Ritual" => "banned",
    "Demonic Tutor" => "banned",
    "Lightning Bolt" => "banned",
    "Channel" => "banned",
    "Natural Order" => "banned",
  )

  change(
    "2021-05-20",
    "https://magic.wizards.com/en/articles/archive/news/may-19-2021-banned-and-restricted-announcement",
    "Thassa's Oracle" => "banned",
  )

  change(
    "2021-06-09",
    "https://magic.wizards.com/en/articles/archive/news/june-9-2021-banned-and-restricted-announcement",
    "Time Warp" => "banned",
  )

  change(
    "2021-07-21",
    "https://magic.wizards.com/en/articles/archive/news/july-21-2021-banned-and-restricted-announcement",
    "Brainstorm" => "banned",
  )

  # J21 conjured
  change(
    "2021-08-26",
    nil,
    "Kraken Hatchling" => "conjurable",
    "Ponder" => "conjurable",
    "Regal Force" => "conjurable",
    "Stormfront Pegasus" => "conjurable",
    "Tropical Island" => "conjurable",
  )

  change(
    "2021-10-13",
    "https://magic.wizards.com/en/articles/archive/news/october-13-2021-banned-and-restricted-announcement",
    "Tibalt's Trickery" => "banned",
    "Memory Lapse" => "banned",
  )

  change(
    "2022-01-25",
    "https://magic.wizards.com/en/articles/archive/news/january-25-2022-banned-and-restricted-announcement",
    # Memory Lapse is banned (from suspended).
    "Teferi, Time Raveler" => "legal", # rebalanced version
  )

  # HBG conjured/specialized
  change(
    "2022-07-07",
    nil,
    # Specialized cards
    "Alora, Cheerful Assassin" => "specialized",
    "Alora, Cheerful Mastermind" => "specialized",
    "Alora, Cheerful Scout" => "specialized",
    "Alora, Cheerful Swashbuckler" => "specialized",
    "Alora, Cheerful Thief" => "specialized",
    "Ambergris, Agent of Balance" => "specialized",
    "Ambergris, Agent of Destruction" => "specialized",
    "Ambergris, Agent of Law" => "specialized",
    "Ambergris, Agent of Progress" => "specialized",
    "Ambergris, Agent of Tyranny" => "specialized",
    "Gale, Abyssal Conduit" => "specialized",
    "Gale, Holy Conduit" => "specialized",
    "Gale, Primeval Conduit" => "specialized",
    "Gale, Storm Conduit" => "specialized",
    "Gale, Temporal Conduit" => "specialized",
    "Gut, Bestial Fanatic" => "specialized",
    "Gut, Brutal Fanatic" => "specialized",
    "Gut, Devious Fanatic" => "specialized",
    "Gut, Furious Fanatic" => "specialized",
    "Gut, Zealous Fanatic" => "specialized",
    "Imoen, Chaotic Trickster" => "specialized",
    "Imoen, Honorable Trickster" => "specialized",
    "Imoen, Occult Trickster" => "specialized",
    "Imoen, Wily Trickster" => "specialized",
    "Imoen, Wise Trickster" => "specialized",
    "Jaheira, Heroic Harper" => "specialized",
    "Jaheira, Insightful Harper" => "specialized",
    "Jaheira, Merciful Harper" => "specialized",
    "Jaheira, Ruthless Harper" => "specialized",
    "Jaheira, Stirring Harper" => "specialized",
    "Karlach, Tiefling Berserker" => "specialized",
    "Karlach, Tiefling Guardian" => "specialized",
    "Karlach, Tiefling Punisher" => "specialized",
    "Karlach, Tiefling Spellrager" => "specialized",
    "Karlach, Tiefling Zealot" => "specialized",
    "Klement, Death Acolyte" => "specialized",
    "Klement, Knowledge Acolyte" => "specialized",
    "Klement, Life Acolyte" => "specialized",
    "Klement, Nature Acolyte" => "specialized",
    "Klement, Tempest Acolyte" => "specialized",
    "Lae'zel, Blessed Warrior" => "specialized",
    "Lae'zel, Callous Warrior" => "specialized",
    "Lae'zel, Illithid Thrall" => "specialized",
    "Lae'zel, Primal Warrior" => "specialized",
    "Lae'zel, Wrathful Warrior" => "specialized",
    "Lukamina, Bear Form" => "specialized",
    "Lukamina, Crocodile Form" => "specialized",
    "Lukamina, Hawk Form" => "specialized",
    "Lukamina, Scorpion Form" => "specialized",
    "Lukamina, Wolf Form" => "specialized",
    "Lulu, Curious Hollyphant" => "specialized",
    "Lulu, Helpful Hollyphant" => "specialized",
    "Lulu, Inspiring Hollyphant" => "specialized",
    "Lulu, Vengeful Hollyphant" => "specialized",
    "Lulu, Wild Hollyphant" => "specialized",
    "Rasaad, Dragon Monk" => "specialized",
    "Rasaad, Radiant Monk" => "specialized",
    "Rasaad, Shadow Monk" => "specialized",
    "Rasaad, Sylvan Monk" => "specialized",
    "Rasaad, Warrior Monk" => "specialized",
    "Sarevok, Deadly Usurper" => "specialized",
    "Sarevok, Deceitful Usurper" => "specialized",
    "Sarevok, Divine Usurper" => "specialized",
    "Sarevok, Ferocious Usurper" => "specialized",
    "Sarevok, Mighty Usurper" => "specialized",
    "Shadowheart, Cleric of Graves" => "specialized",
    "Shadowheart, Cleric of Order" => "specialized",
    "Shadowheart, Cleric of Trickery" => "specialized",
    "Shadowheart, Cleric of Twilight" => "specialized",
    "Shadowheart, Cleric of War" => "specialized",
    "Skanos, Black Dragon Vassal" => "specialized",
    "Skanos, Blue Dragon Vassal" => "specialized",
    "Skanos, Green Dragon Vassal" => "specialized",
    "Skanos, Red Dragon Vassal" => "specialized",
    "Skanos, White Dragon Vassal" => "specialized",
    "Vhal, Scholar of Creation" => "specialized",
    "Vhal, Scholar of Elements" => "specialized",
    "Vhal, Scholar of Mortality" => "specialized",
    "Vhal, Scholar of Prophecy" => "specialized",
    "Vhal, Scholar of Tactics" => "specialized",
    "Viconia, Disciple of Arcana" => "specialized",
    "Viconia, Disciple of Blood" => "specialized",
    "Viconia, Disciple of Rebirth" => "specialized",
    "Viconia, Disciple of Strength" => "specialized",
    "Viconia, Disciple of Violence" => "specialized",
    "Wilson, Ardent Bear" => "specialized",
    "Wilson, Fearsome Bear" => "specialized",
    "Wilson, Majestic Bear" => "specialized",
    "Wilson, Subtle Bear" => "specialized",
    "Wilson, Urbane Bear" => "specialized",
    "Wyll of the Blade Pact" => "specialized",
    "Wyll of the Celestial Pact" => "specialized",
    "Wyll of the Elder Pact" => "specialized",
    "Wyll of the Fey Pact" => "specialized",
    "Wyll of the Fiend Pact" => "specialized",
    # conjure only cards
    "Hag of Ceaseless Torment" => "conjurable",
    "Hag of Dark Duress" => "conjurable",
    "Hag of Death's Legion" => "conjurable",
    "Hag of Inner Weakness" => "conjurable",
    "Hag of Mage's Doom" => "conjurable",
    "Hag of Noxious Nightmares" => "conjurable",
    "Hag of Scoured Thoughts" => "conjurable",
    "Hag of Syphoned Breath" => "conjurable",
    "Hag of Twisted Visions" => "conjurable",
    # Now this is fun, HBG cards 900+ are conjure only, but some of these have other historic legal printings
    # It would be better to move these to a separate set
    # "Archipelagore" => "conjurable", # also in IKO
    # "Junk Winder" => "conjurable", # also in J21
    # "Moat Piranhas" => "conjurable", # also in M20
    # "Mystic Skyfish" => "conjurable", # also in M21
    # "Nadir Kraken" => "conjurable", # also in THB
    # "Nezahal, Primal Tide" => "conjurable", # also in RIX
    # "Pouncing Shoreshark" => "conjurable", # also in IKO
    # "Pursued Whale" => "conjurable", # also in M21
    # "Riptide Turtle" => "conjurable", # also in THB
    # "Ruin Crab" => "conjurable", # also in ZNR
    # "Sea-Dasher Octopus" => "conjurable", # also in IKO
    # "Sigiled Starfish" => "conjurable", # also in JMP
    # "Spined Megalodon" => "conjurable", # also in M21
    # "Stinging Lionfish" => "conjurable", # also in THB
    # "Voracious Greatshark" => "conjurable", # also in IKO
    "Lightning Bolt" => "conjurable", # well, it was pre-banned, but now it's conjurable, so this is fine
    # "Naturalize" => "conjurable", # also in M19
    # "Plummet" => "conjurable", # also in M20
  )

  # YDMU
  change(
    "2022-10-05",
    nil,
    # conjure only cards
    "Ancestral Recall" => "conjurable",
    "Time Walk" => "conjurable",
    "Timetwister" => "conjurable",
    "Black Lotus" => "conjurable",
    "Mox Emerald" => "conjurable",
    "Mox Jet" => "conjurable",
    "Mox Pearl" => "conjurable",
    "Mox Ruby" => "conjurable",
    "Mox Sapphire" => "conjurable",
  )

  # BRR preemptively banned
  change(
    "2022-11-18",
    "https://twitter.com/MTG_Arena/status/1586775900842074126",
    "Mishra's Bauble" => "banned",
  )

  # MUL preemptively banned
  change(
    "2023-04-21",
    nil,
    "Ragavan, Nimble Pilferer" => "banned",
  )

  change(
    "2023-08-15",
    "https://twitter.com/MTG_Arena/status/1691515167111000064",
    "Blood Moon" => "banned",
    "Intruder Alarm" => "banned",
    "Land Tax" => "banned",
    "Necropotence" => "banned",
    "Sneak Attack" => "banned",
    "Spreading Seas" => "banned",
  )

  change(
    "2023-12-04",
    "https://magic.wizards.com/en/news/mtg-arena/introducing-timeless-a-new-mtg-arena-format",
    "Flooded Strand" => "banned",
    "Polluted Delta" => "banned",
    "Bloodstained Mire" => "banned",
    "Wooded Foothills" => "banned",
    "Windswept Heath" => "banned",
  )

  change(
    "2024-02-05",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-february-5-2024",
    "Show and Tell" => "banned",
  )

  change(
    "2024-04-08",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-april-8-2024",
    "Commandeer" => "banned",
    "Force of Vigor" => "banned",
    "Mana Drain" => "banned",
    "Reanimate" => "banned",
  )

  change(
    "2024-06-03",
    "http://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-june-3-2024",
    "Harbinger of the Seas" => "banned",
    "Winter Moon" => "banned",
    "Solitude" => "banned",
    "Subtlety" => "banned",
    "Grief" => "banned",
    "Fury" => "banned",
    "Endurance" => "banned",
    "Flare of Fortitude" => "banned",
    "Flare of Denial" => "banned",
    "Flare of Malice" => "banned",
    "Flare of Duplication" => "banned",
    "Flare of Cultivation" => "banned",
    "Marsh Flats" => "banned",
    "Scalding Tarn" => "banned",
    "Verdant Catacombs" => "banned",
    "Arid Mesa" => "banned",
    "Misty Rainforest" => "banned",
  )

  change(
    "2024-11-12",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-november-11-2024",
    "Temporal Manipulation" => "banned",
  )

  change(
    "2025-02-03",
    "https://magic.wizards.com/en/news/mtg-arena/announcements-february-3-2025",
    "Chrome Mox" => "banned",
  )

  change(
    "2025-06-30",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-june-30-2025",
    "Counterspell" => "legal",
  )

  change(
    "2025-07-21",
    "https://magic.wizards.com/en/news/mtg-arena/announcements-july-21-2025",
    "Ancient Tomb" => "banned",
    "Strip Mine" => "banned",
    "Magus of the Moon" => "banned",
  )

  # pre-banned, came to Arena with AA2 the next day
  change(
    "2025-08-18",
    "https://magic.wizards.com/en/news/mtg-arena/announcements-august-18-2025",
    "Mox Opal" => "banned",
  )

  # pre-banned, came to Arena with AA3 on 2025-09-23
  change(
    "2025-09-16",
    "https://magic.wizards.com/en/news/mtg-arena/through-the-omenpaths-card-and-event-updates",
    "Broadside Bombardiers" => "banned",
    "Gut, True Soul Zealot" => "banned",
  )

  # Not a banlist change. AA4 and the OMB bonus sheet put four of the five J21 conjured
  # cards into the normal Arena card pool.
  #
  # AA4 is 28 cards, 25 of them new to Arena, and it conjures nothing - an ordinary
  # release, so a card printed in it is an ordinary card.
  #
  # OMB is the bonus sheet of Through the Omenpaths, and the release FAQ settles it
  # outright: "Those cards are legal for play in Historic, Timeless, and Brawl as well as
  # any other format where a card with the same name is already permitted."
  # https://magic.wizards.com/en/news/mtg-arena/through-the-omenpaths-release-faq
  # Reanimate is the only OMB card that stays unplayable in Historic, and that's an
  # ordinary ban (2024-04-08), not conjure-only status. Ponder is still conjured by
  # Preponderant Pearl in YECL, which is no obstacle - a card can be both.
  #
  # Tropical Island is still conjure-only, J21 is still its only Arena printing.
  change(
    "2025-09-23",
    nil,
    "Kraken Hatchling" => "legal", # aa4
    "Regal Force" => "legal", # aa4
    "Stormfront Pegasus" => "legal", # aa4
    "Ponder" => "legal", # omb
  )

  # pre-banned, came to Arena in Powered Cube prize packs when the event started on 2025-10-28
  change(
    "2025-10-20",
    "https://magic.wizards.com/en/news/mtg-arena/announcing-the-arena-powered-cube",
    "Fireblast" => "banned",
    "Preordain" => "banned",
    "Pyrokinesis" => "banned",
    "Seething Song" => "banned",
  )

  change(
    "2025-11-10",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-november-10-2025",
    # pre-banned
    "Force of Negation" => "banned",
    "Frantic Search" => "banned",
    "Mystical Tutor" => "banned",
    "Entomb" => "banned",
    "Dark Depths" => "banned",
  )

  # pre-banned, came to Arena as Lorwyn Eclipsed Special Guests on 2026-01-23
  change(
    "2026-01-12",
    "https://magic.wizards.com/en/news/mtg-arena/announcements-january-12-2026",
    "Devoted Druid" => "banned",
    "Painter's Servant" => "banned",
  )

  change(
    "2026-02-09",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-february-9-2026",
    "Eldrazi Temple" => "banned",
    "Ajani, Nacatl Pariah" => "banned",
    "Crop Rotation" => "banned",
    "Scholar of the Lost Trove" => "banned",
    "Magus of the Moon" => "legal",
    "Harbinger of the Seas" => "legal",
    "Force of Vigor" => "legal",
    "Force of Negation" => "legal",
    "Endurance" => "legal",
    "Wilderness Reclamation" => "legal",
    "Agent of Treachery" => "legal",
  )

  change(
    "2026-03-23",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-march-23-2026",
    "Food Chain" => "banned",
  )

  change(
    "2026-03-30",
    "https://magic.wizards.com/en/news/mtg-arena/arena-powered-cube-draft",
    "Survival of the Fittest" => "banned",
  )

  change(
    "2026-04-20",
    "https://magic.wizards.com/en/news/mtg-arena/announcements-april-20-2026",
    "Armageddon" => "banned",
    "Daze" => "banned",
    "Force of Will" => "banned",
    "Vampiric Tutor" => "banned",
    "Library of Alexandria" => "banned",
  )
end

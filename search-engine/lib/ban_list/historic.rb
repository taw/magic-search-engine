# This banlist doesn't distinguish "suspended" from "banned"
# "restricted" status is used for conjured/specialized cards, which is technically not a B&R issue

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
    "Tropical Island" => "restricted",
    "Regal Force" => "restricted",
    "Stormfront Pegasus" => "restricted",
    "Kraken Hatchling" => "restricted",
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
    "Alora, Cheerful Assassin" => "restricted",
    "Alora, Cheerful Mastermind" => "restricted",
    "Alora, Cheerful Scout" => "restricted",
    "Alora, Cheerful Swashbuckler" => "restricted",
    "Alora, Cheerful Thief" => "restricted",
    "Ambergris, Agent of Balance" => "restricted",
    "Ambergris, Agent of Destruction" => "restricted",
    "Ambergris, Agent of Law" => "restricted",
    "Ambergris, Agent of Progress" => "restricted",
    "Ambergris, Agent of Tyranny" => "restricted",
    "Gale, Abyssal Conduit" => "restricted",
    "Gale, Holy Conduit" => "restricted",
    "Gale, Primeval Conduit" => "restricted",
    "Gale, Storm Conduit" => "restricted",
    "Gale, Temporal Conduit" => "restricted",
    "Gut, Bestial Fanatic" => "restricted",
    "Gut, Brutal Fanatic" => "restricted",
    "Gut, Devious Fanatic" => "restricted",
    "Gut, Furious Fanatic" => "restricted",
    "Gut, Zealous Fanatic" => "restricted",
    "Imoen, Chaotic Trickster" => "restricted",
    "Imoen, Honorable Trickster" => "restricted",
    "Imoen, Occult Trickster" => "restricted",
    "Imoen, Wily Trickster" => "restricted",
    "Imoen, Wise Trickster" => "restricted",
    "Jaheira, Heroic Harper" => "restricted",
    "Jaheira, Insightful Harper" => "restricted",
    "Jaheira, Merciful Harper" => "restricted",
    "Jaheira, Ruthless Harper" => "restricted",
    "Jaheira, Stirring Harper" => "restricted",
    "Karlach, Tiefling Berserker" => "restricted",
    "Karlach, Tiefling Guardian" => "restricted",
    "Karlach, Tiefling Punisher" => "restricted",
    "Karlach, Tiefling Spellrager" => "restricted",
    "Karlach, Tiefling Zealot" => "restricted",
    "Klement, Death Acolyte" => "restricted",
    "Klement, Knowledge Acolyte" => "restricted",
    "Klement, Life Acolyte" => "restricted",
    "Klement, Nature Acolyte" => "restricted",
    "Klement, Tempest Acolyte" => "restricted",
    "Lae'zel, Blessed Warrior" => "restricted",
    "Lae'zel, Callous Warrior" => "restricted",
    "Lae'zel, Illithid Thrall" => "restricted",
    "Lae'zel, Primal Warrior" => "restricted",
    "Lae'zel, Wrathful Warrior" => "restricted",
    "Lukamina, Bear Form" => "restricted",
    "Lukamina, Crocodile Form" => "restricted",
    "Lukamina, Hawk Form" => "restricted",
    "Lukamina, Scorpion Form" => "restricted",
    "Lukamina, Wolf Form" => "restricted",
    "Lulu, Curious Hollyphant" => "restricted",
    "Lulu, Helpful Hollyphant" => "restricted",
    "Lulu, Inspiring Hollyphant" => "restricted",
    "Lulu, Vengeful Hollyphant" => "restricted",
    "Lulu, Wild Hollyphant" => "restricted",
    "Rasaad, Dragon Monk" => "restricted",
    "Rasaad, Radiant Monk" => "restricted",
    "Rasaad, Shadow Monk" => "restricted",
    "Rasaad, Sylvan Monk" => "restricted",
    "Rasaad, Warrior Monk" => "restricted",
    "Sarevok, Deadly Usurper" => "restricted",
    "Sarevok, Deceitful Usurper" => "restricted",
    "Sarevok, Divine Usurper" => "restricted",
    "Sarevok, Ferocious Usurper" => "restricted",
    "Sarevok, Mighty Usurper" => "restricted",
    "Shadowheart, Cleric of Graves" => "restricted",
    "Shadowheart, Cleric of Order" => "restricted",
    "Shadowheart, Cleric of Trickery" => "restricted",
    "Shadowheart, Cleric of Twilight" => "restricted",
    "Shadowheart, Cleric of War" => "restricted",
    "Skanos, Black Dragon Vassal" => "restricted",
    "Skanos, Blue Dragon Vassal" => "restricted",
    "Skanos, Green Dragon Vassal" => "restricted",
    "Skanos, Red Dragon Vassal" => "restricted",
    "Skanos, White Dragon Vassal" => "restricted",
    "Vhal, Scholar of Creation" => "restricted",
    "Vhal, Scholar of Elements" => "restricted",
    "Vhal, Scholar of Mortality" => "restricted",
    "Vhal, Scholar of Prophecy" => "restricted",
    "Vhal, Scholar of Tactics" => "restricted",
    "Viconia, Disciple of Arcana" => "restricted",
    "Viconia, Disciple of Blood" => "restricted",
    "Viconia, Disciple of Rebirth" => "restricted",
    "Viconia, Disciple of Strength" => "restricted",
    "Viconia, Disciple of Violence" => "restricted",
    "Wilson, Ardent Bear" => "restricted",
    "Wilson, Fearsome Bear" => "restricted",
    "Wilson, Majestic Bear" => "restricted",
    "Wilson, Subtle Bear" => "restricted",
    "Wilson, Urbane Bear" => "restricted",
    "Wyll of the Blade Pact" => "restricted",
    "Wyll of the Celestial Pact" => "restricted",
    "Wyll of the Elder Pact" => "restricted",
    "Wyll of the Fey Pact" => "restricted",
    "Wyll of the Fiend Pact" => "restricted",
    # conjure only cards
    "Hag of Ceaseless Torment" => "restricted",
    "Hag of Dark Duress" => "restricted",
    "Hag of Death's Legion" => "restricted",
    "Hag of Inner Weakness" => "restricted",
    "Hag of Mage's Doom" => "restricted",
    "Hag of Noxious Nightmares" => "restricted",
    "Hag of Scoured Thoughts" => "restricted",
    "Hag of Syphoned Breath" => "restricted",
    "Hag of Twisted Visions" => "restricted",
    # Now this is fun, HBG cards 900+ are conjure only, but some of these have other historic legal printings
    # It would be better to move these to a separete set
    # "Archipelagore" => "restricted", # also in IKO
    # "Junk Winder" => "restricted", # also in J21
    # "Moat Piranhas" => "restricted", # also in M20
    # "Mystic Skyfish" => "restricted", # also in M21
    # "Nadir Kraken" => "restricted", # also in THB
    # "Nezahal, Primal Tide" => "restricted", # also in RIX
    # "Pouncing Shoreshark" => "restricted", # also in IKO
    # "Pursued Whale" => "restricted", # also in M21
    # "Riptide Turtle" => "restricted", # also in THB
    # "Ruin Crab" => "restricted", # also in ZNR
    # "Sea-Dasher Octopus" => "restricted", # also in IKO
    # "Sigiled Starfish" => "restricted", # also in JMP
    # "Spined Megalodon" => "restricted", # also in M21
    # "Stinging Lionfish" => "restricted", # also in THB
    # "Voracious Greatshark" => "restricted", # also in IKO
    "Lightning Bolt" => "restricted", # well, it was pre-banned, but now it's conjurable, so this is fine
    # "Naturalize" => "restricted", # also in M19
    # "Plummet" => "restricted", # also in M20
  )

  # YDMU
  change(
    "2022-10-05",
    nil,
    # conjure only cards
    "Ancestral Recall" => "restricted",
    "Time Walk" => "restricted",
    "Timetwister" => "restricted",
    "Black Lotus" => "restricted",
    "Mox Emerald" => "restricted",
    "Mox Jet" => "restricted",
    "Mox Pearl" => "restricted",
    "Mox Ruby" => "restricted",
    "Mox Sapphire" => "restricted",
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
end

# "conjurable" and "specialized" are technically not a B&R issue, they're cards which
# can't go into a deck at all. Format::RESTRICTED_STATUSES groups them with the
# other restricted-family statuses for restricted: and f: searches - see _LEGALITY.md

BanList.for_format("alchemy") do
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
    "Archipelagore" => "conjurable",
    "Junk Winder" => "conjurable",
    "Moat Piranhas" => "conjurable",
    "Mystic Skyfish" => "conjurable",
    "Nadir Kraken" => "conjurable",
    "Nezahal, Primal Tide" => "conjurable",
    "Pouncing Shoreshark" => "conjurable",
    "Pursued Whale" => "conjurable",
    "Riptide Turtle" => "conjurable",
    "Ruin Crab" => "conjurable",
    "Sea-Dasher Octopus" => "conjurable",
    "Sigiled Starfish" => "conjurable",
    "Spined Megalodon" => "conjurable",
    "Stinging Lionfish" => "conjurable",
    "Voracious Greatshark" => "conjurable",
    "Lightning Bolt" => "conjurable",
    "Naturalize" => "conjurable",
    # "Plummet" => "conjurable", # also in MID (rotates with HBG)
  )

  # YDMU - it would be better to move these to a separate set
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

  change(
    "2023-07-18",
    "https://magic.wizards.com/en/news/mtg-arena/alchemy-rebalancing-for-july-18-2023",
    "Fable of the Mirror-Breaker" => "banned",
  )

  change(
    "2024-11-12",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-november-11-2024",
    "Monstrous Rage" => "banned",
  )

  # This isn't really a banlist change, a previously conjurable card (from Oyaminartok's spellbook)
  # got printed into Alchemy-legal set FDN
  change(
    "2024-12-15",
    nil,
    "Voracious Greatshark" => "legal"
  )

  change(
    "2025-06-30",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-june-30-2025",
    # suspended (pending rebalance).
    "Cori-Steel Cutter" => "banned",
  )

  change(
    "2026-05-18",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-may-18-2026",
    "Sewer-veillance Cam" => "banned",
  )
end

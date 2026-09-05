BanList.for_format("timeless") do
  # "conjurable" and "specialized" are technically not a B&R issue, they're cards which
  # can't go into a deck at all. Format::RESTRICTED_STATUSES groups them with the
  # other restricted-family statuses for restricted: and f: searches.
  #
  # Same list as Historic's - conjure-only is a property of the card on Arena, not of a
  # format - but kept as its own copy so a new conjure-only set gets its own dated entry
  # here instead of being backdated into this block. Lightning Bolt is the one card
  # Historic has that this doesn't: it files it as conjurable because it's pre-banned
  # there anyway, but it's an ordinary craftable card (STA, FCA, TLE, MSC) here.
  #
  # Every one of these predates the format, hence the single undated block. Brawler's
  # Plate, Soul of New Phyrexia and Thieving Magpie are there for that reason and not
  # with the dated Alchemy appendices below: YONE, YWOE and YLCI all conjured them before
  # Timeless existed.
  format_start(
    "Cards which can only be conjured or specialized into, never put in a deck",
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
    "Ancestral Recall" => "conjurable",
    "Black Lotus" => "conjurable",
    "Brawler's Plate" => "conjurable",
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
    "Hag of Ceaseless Torment" => "conjurable",
    "Hag of Dark Duress" => "conjurable",
    "Hag of Death's Legion" => "conjurable",
    "Hag of Inner Weakness" => "conjurable",
    "Hag of Mage's Doom" => "conjurable",
    "Hag of Noxious Nightmares" => "conjurable",
    "Hag of Scoured Thoughts" => "conjurable",
    "Hag of Syphoned Breath" => "conjurable",
    "Hag of Twisted Visions" => "conjurable",
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
    "Kraken Hatchling" => "conjurable",
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
    "Mox Emerald" => "conjurable",
    "Mox Jet" => "conjurable",
    "Mox Pearl" => "conjurable",
    "Mox Ruby" => "conjurable",
    "Mox Sapphire" => "conjurable",
    "Ponder" => "conjurable",
    "Rasaad, Dragon Monk" => "specialized",
    "Rasaad, Radiant Monk" => "specialized",
    "Rasaad, Shadow Monk" => "specialized",
    "Rasaad, Sylvan Monk" => "specialized",
    "Rasaad, Warrior Monk" => "specialized",
    "Regal Force" => "conjurable",
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
    "Soul of New Phyrexia" => "conjurable",
    "Stormfront Pegasus" => "conjurable",
    "Thieving Magpie" => "conjurable",
    "Time Walk" => "conjurable",
    "Timetwister" => "conjurable",
    "Tropical Island" => "conjurable",
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
  )

  # Timeless has never banned anything - "basically no bans" is the whole point of the
  # format - so restriction is all there is below.
  change(
    "2023-12-12",
    "https://magic.wizards.com/en/news/mtg-arena/introducing-timeless-a-new-mtg-arena-format",
    "Channel" => "restricted",
    "Demonic Tutor" => "restricted",
    "Tibalt's Trickery" => "restricted",
  )

  # Most Alchemy sets since YBRO end with an appendix of conjure-only cards, numbered
  # after every normal card in the set. mtgjson only shipped those printings in
  # 5.3.0+20260901, dated to their original release, so they read as plainly legal here
  # for years - hence entries backdated into the history rather than appended at the end.
  #
  # YDFT
  change(
    "2025-03-04",
    "This card is conjurable only",
    "Muraganda Petroglyphs" => "conjurable",
  )

  # YEOE
  change(
    "2025-08-19",
    "This card is conjurable only",
    "Flametongue Kavu" => "conjurable",
  )

  # Not a ban list change - Arena Anthology 4 printed these four as ordinary cards, so
  # they stopped being conjure-only
  change(
    "2025-09-23",
    "https://magic.wizards.com/en/news/mtg-arena/through-the-omenpaths-card-and-event-updates",
    "Kraken Hatchling" => "legal",
    "Ponder" => "legal",
    "Regal Force" => "legal",
    "Stormfront Pegasus" => "legal",
  )

  # YECL
  change(
    "2026-02-03",
    "These cards are conjurable only",
    "Blowfly Infestation" => "conjurable",
    "Rite of Flame" => "conjurable",
    "Stonybrook Schoolmaster" => "conjurable",
  )

  change(
    "2026-02-09",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-february-9-2026",
    "Necropotence" => "restricted",
  )

  # YSOS
  change(
    "2026-05-19",
    "These cards are conjurable only",
    "Bridge from Below" => "conjurable",
    "Storm Crow" => "conjurable",
  )
end

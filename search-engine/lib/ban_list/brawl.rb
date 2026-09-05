BanList.for_format("brawl") do
  # Launched as Historic Brawl. The article is dated 2020-12-21 on mtg.wiki and
  # 2020-12-22 on the live page; nothing here turns on which.
  format_start(
    "https://magic.wizards.com/en/articles/archive/magic-digital/historic-brawl-2020-12-21",
    "Drannith Magistrate" => "banned",
    "Gideon's Intervention" => "banned",
    "Golos, Tireless Pilgrim" => "banned",
    "Lutri, the Spellchaser" => "banned",
    "Meddling Mage" => "banned",
    "Nexus of Fate" => "banned",
    "Oko, Thief of Crowns" => "banned",
    "Runed Halo" => "banned",
    "Sorcerous Spyglass" => "banned",
    "Teferi, Time Raveler" => "banned",
    "Winota, Joiner of Forces" => "banned",
  )

  # Announced 2021-04-14, effective with the Strixhaven launch. Four Mystical Archive
  # cards; the announcement is explicit that the four Historic pre-banned off the same
  # sheet - Counterspell, Dark Ritual, Lightning Bolt, Swords to Plowshares - stay legal
  # here.
  change(
    "2021-04-15",
    "https://magic.wizards.com/en/articles/archive/magic-digital/mtg-arena-announcements-april-14-2021",
    "Channel" => "banned",
    "Demonic Tutor" => "banned",
    "Natural Order" => "banned",
    "Tainted Pact" => "banned",
  )

  # Announced 2021-06-16, effective 2021-06-19 with the move to 100-card decks
  change(
    "2021-06-19",
    "https://magic.wizards.com/en/articles/archive/magic-digital/mtg-arena-announcements-june-16-2021",
    "Golos, Tireless Pilgrim" => "legal",
    "Winota, Joiner of Forces" => "legal",
  )

  # "conjurable" and "specialized" are technically not a B&R issue, they're cards which
  # can't go into a deck at all. Format::RESTRICTED_STATUSES groups them with the
  # other restricted-family statuses for restricted: and f: searches.
  #
  # Same cards as Historic's copy of this list, minus Lightning Bolt - Historic files
  # that one as conjurable because it's pre-banned there anyway, but it's an ordinary
  # craftable card (STA, FCA, TLE, MSC) here. Brawl is older than every conjure-only
  # set, so unlike Timeless's these get real dates.
  change(
    "2021-08-26",
    "These cards are conjurable only",
    "Kraken Hatchling" => "conjurable",
    "Ponder" => "conjurable",
    "Regal Force" => "conjurable",
    "Stormfront Pegasus" => "conjurable",
    "Tropical Island" => "conjurable",
  )

  change(
    # The tweet bans it "in both Brawl and Historic Brawl", so it's in this file and in
    # standard_brawl.rb both
    "2021-10-01",
    "https://twitter.com/Wizards_Help/status/1443994094200623122",
    "Pithing Needle" => "banned",
  )

  # Announced 2021-12-08, effective 2021-12-09 with the Alchemy launch
  change(
    "2021-12-09",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-december-08-2021",
    "Agent of Treachery" => "banned",
    "Field of the Dead" => "banned",
    "Ugin, the Spirit Dragon" => "banned",
  )

  change(
    # The announcement doesn't mention Brawl at all - it unbans the rebalanced Teferi in
    # Historic, and Brawl's copy of the ban went with it. mtg.wiki cites this article for
    # the Brawl unban too, and no other source dates it.
    "2022-01-25",
    "https://magic.wizards.com/en/articles/archive/news/january-25-2022-banned-and-restricted-announcement",
    "Teferi, Time Raveler" => "legal",
  )

  change(
    "2022-07-07",
    "These cards are specialized/conjurable only",
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
  )

  change(
    "2022-08-04",
    "https://magic.wizards.com/en/news/mtg-arena/patch-notes-20221810",
    "Chalice of the Void" => "banned",
  )

  change(
    "2022-10-05",
    "These cards are conjurable only",
    "Ancestral Recall" => "conjurable",
    "Black Lotus" => "conjurable",
    "Mox Emerald" => "conjurable",
    "Mox Jet" => "conjurable",
    "Mox Pearl" => "conjurable",
    "Mox Ruby" => "conjurable",
    "Mox Sapphire" => "conjurable",
    "Time Walk" => "conjurable",
    "Timetwister" => "conjurable",
  )

  # Announced 2022-11-09 in the Brothers' War State of the Game, effective when BRR
  # reached Arena on 2022-11-18
  change(
    "2022-11-18",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-state-of-the-game-the-brothers-war",
    "Phyrexian Revoker" => "prebanned",
  )

  # Most Alchemy sets since YBRO end with an appendix of conjure-only cards, numbered
  # after every normal card in the set. mtgjson only shipped those printings in
  # 5.3.0+20260901, dated to their original release, so they read as plainly legal here
  # for years - hence entries backdated into the history rather than appended at the end.
  #
  # YONE
  change(
    "2023-02-28",
    "This card is conjurable only",
    "Soul of New Phyrexia" => "conjurable",
  )

  # YWOE
  change(
    "2023-10-10",
    "This card is conjurable only",
    "Brawler's Plate" => "conjurable",
  )

  # YLCI
  change(
    "2023-12-05",
    "This card is conjurable only",
    "Thieving Magpie" => "conjurable",
  )

  # Announced 2024-06-03, effective when Modern Horizons 3 reached Arena on 2024-06-14
  change(
    "2024-06-14",
    "https://magic.wizards.com/en/news/mtg-arena/mtg-arena-announcements-june-3-2024",
    "Disruptor Flute" => "prebanned",
  )

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

  # Announced 2025-09-16, effective when Arena Anthology 4 landed on 2025-09-23. The four
  # unbans aren't a ban list decision - AA4 printed them as ordinary cards, so they
  # stopped being conjure-only.
  change(
    "2025-09-23",
    "https://magic.wizards.com/en/news/mtg-arena/through-the-omenpaths-card-and-event-updates",
    "Iona, Shield of Emeria" => "prebanned",
    "Kraken Hatchling" => "legal",
    "Ponder" => "legal",
    "Regal Force" => "legal",
    "Stormfront Pegasus" => "legal",
  )

  change(
    "2025-11-10",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-november-10-2025",
    "Ancient Tomb" => "banned",
    "Chrome Mox" => "banned",
    "Mana Drain" => "banned",
    "Strip Mine" => "banned",
  )

  # No announcement exists for these five. The "free if you control a commander" cycle
  # arrived with the Avatar: The Last Airbender Eternal bonus sheet and was banned on the
  # spot; only Fierce Guardianship ever made it onto the official banned list page.
  # mtg.wiki cites "Arena search" for all five, and "Brawl: Our Plans" (2025-12-15)
  # refers to them as already banned when it lists what the Metagame Challenge would
  # re-legalise.
  change(
    "2025-11-21",
    "Silently pre-banned with the TLE bonus sheet - no announcement, dated to the set's Arena release",
    "Deadly Rollick" => "prebanned",
    "Deflecting Swat" => "prebanned",
    "Fierce Guardianship" => "prebanned",
    "Flawless Maneuver" => "prebanned",
    "Obscuring Haze" => "prebanned",
  )

  # YECL
  change(
    "2026-02-03",
    "These cards are conjurable only",
    "Blowfly Infestation" => "conjurable",
    "Rite of Flame" => "conjurable",
    "Stonybrook Schoolmaster" => "conjurable",
  )

  # YSOS
  change(
    "2026-05-19",
    "These cards are conjurable only",
    "Bridge from Below" => "conjurable",
    "Storm Crow" => "conjurable",
  )

  # Announced 2026-05-18, effective 2026-06-29
  change(
    "2026-06-29",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-june-29-2026",
    "Force of Will" => "banned",
    "Subtlety" => "banned",
    "Temporal Manipulation" => "banned",
    "Time Warp" => "banned",
    "Ugin's Labyrinth" => "banned",
    "Wash Away" => "banned",
  )
end

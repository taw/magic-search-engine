BanList.for_format("standard") do
  # The Type II restricted list printed in The Duelist #10 (May 1996), as of the April 1,
  # 1996 changes, is Balance, Black Vise, Ivory Tower and Zuran Orb. Balance and Black Vise
  # have dated restrictions below; these two do not, so they start here.
  # https://archive.org/details/duelist-10
  format_start(
    "https://archive.org/details/duelist-10",
    "Ivory Tower" => "restricted",
    "Zuran Orb" => "restricted",
  )

  change(
    "1995-05-01",
    nil,
    "Balance" => "restricted",
  )

  change(
    "1996-02-01",
    nil,
    "Mind Twist" => "banned",
    "Black Vise" => "restricted",
  )

  change(
    "1996-07-01",
    nil,
    "Land Tax" => "restricted",
  )

  change(
    "1996-10-01",
    nil,
    "Hymn to Tourach" => "restricted",
    "Strip Mine" => "restricted",
  )

  # The announcement that abolished the Standard restricted list and folded it into the
  # banned list. Hymn to Tourach is not on the resulting list: only restricted cards that
  # "remain in the tournament environment after the departure of Fallen Empires and Ice
  # Age" were moved over, and Hymn to Tourach is a Fallen Empires card, so it left the
  # format that day instead of being banned. Ivory Tower is a Fourth Edition card and
  # stayed, so it was banned.
  change(
    "1997-01-01",
    "https://web.archive.org/web/19961219074006/http://www.wizards.com/DCI/ban_rest_letter.html",
    "Balance" => "banned",
    "Black Vise" => "banned",
    "Hymn to Tourach" => "legal",
    "Ivory Tower" => "banned",
    "Land Tax" => "banned",
    "Strip Mine" => "banned",
    # Zuran Orb left with Ice Age the same day, so it is not on the new list. It comes back
    # in Fifth Edition and is banned outright on 1997-07-01.
    "Zuran Orb" => "legal",
  )

  change(
    "1997-07-01",
    nil,
    "Zuran Orb" => "banned",
  )

  change(
    "1999-01-01",
    "https://web.archive.org/web/19990209004446/http://www.wizards.com/DCI/MTG_DCI_BR12-1-98.html",
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
    "Dream Halls" => "banned",
    "Earthcraft" => "banned",
    "Fluctuator" => "banned",
    "Lotus Petal" => "banned",
    "Recurring Nightmare" => "banned",
    "Time Spiral" => "banned",
  )

  change(
    "1999-07-01",
    "http://web.archive.org/web/20111121212434/http://www.crystalkeep.com/magic/rules/dci/update-990601.txt",
    "Mind Over Matter" => "banned",
  )

  change(
    "2004-06-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20040601a",
    "Skullclamp" => "banned",
  )

  change(
    "2005-03-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20050301a",
    "Ancient Den" => "banned",
    "Arcbound Ravager" => "banned",
    "Darksteel Citadel" => "banned",
    "Disciple of the Vault" => "banned",
    "Great Furnace" => "banned",
    "Seat of the Synod" => "banned",
    "Tree of Tales" => "banned",
    "Vault of Whispers" => "banned",
  )

  change(
    "2011-07-01",
    "https://magic.wizards.com/en/articles/archive/feature/june-20-2011-dci-banned-restricted-list-announcement-2011-06-20",
    "Jace, the Mind Sculptor" => "banned",
    "Stoneforge Mystic" => "banned",
  )

  change(
    "2014-07-18",
    "Original ban expired with rotation, reprinted into Standard as a legal card",
    "Darksteel Citadel" => "legal",
  )

  change(
    "2017-01-20",
    "https://magic.wizards.com/en/articles/archive/news/january-9-2017-banned-and-restricted-announcement-2017-01-09",
    "Emrakul, the Promised End" => "banned",
    "Reflector Mage" => "banned",
    "Smuggler's Copter" => "banned",
  )

  change(
    "2017-04-28",
    "https://magic.wizards.com/en/articles/archive/news/addendum-april-24-2017-banned-and-restricted-announcement-2017-04-26",
    "Felidar Guardian" => "banned",
  )

  change(
    "2017-06-19",
    "https://magic.wizards.com/en/articles/archive/feature/june-13-2017-banned-and-restricted-announcement-2017-06-13",
    "Aetherworks Marvel" => "banned",
  )

  change(
    "2018-01-19",
    "https://magic.wizards.com/en/articles/archive/news/january-15-2018-banned-and-restricted-announcement-2018-01-15",
    "Attune with Aether" => "banned",
    "Rogue Refiner" => "banned",
    "Rampaging Ferocidon" => "banned",
    "Ramunap Ruins" => "banned",
  )

  change(
    "2019-08-30",
    "https://magic.wizards.com/en/articles/archive/news/august-26-2019-banned-and-restricted-announcement-2019-08-26",
    "Rampaging Ferocidon" => "legal",
  )

  change(
    "2019-10-21",
    "https://magic.wizards.com/en/articles/archive/news/october-21-2019-banned-and-restricted-announcement",
    "Field of the Dead" => "banned",
  )

  change(
    "2019-11-18",
    "https://magic.wizards.com/en/articles/archive/news/november-18-2019-banned-and-restricted-announcement",
    "Oko, Thief of Crowns" => "banned",
    "Once Upon a Time" => "banned",
    "Veil of Summer" => "banned",
  )

  change(
    "2020-06-01",
    "https://magic.wizards.com/en/articles/archive/news/june-1-2020-banned-and-restricted-announcement",
    "Agent of Treachery" => "banned",
    "Fires of Invention" => "banned",
  )

  change(
    "2020-08-03",
    "https://magic.wizards.com/en/articles/archive/news/august-8-2020-banned-and-restricted-announcement",
    "Wilderness Reclamation" => "banned",
    "Growth Spiral" => "banned",
    "Teferi, Time Raveler" => "banned",
    "Cauldron Familiar" => "banned",
  )

  change(
    "2020-09-28",
    "https://magic.wizards.com/en/articles/archive/news/september-28-2020-banned-and-restricted-announcement-2020-09-28",
    "Uro, Titan of Nature's Wrath" => "banned",
  )

  change(
    "2020-10-12",
    "https://magic.wizards.com/en/articles/archive/news/october-12-2020-banned-and-restricted-announcement",
    "Omnath, Locus of Creation" => "banned",
    "Lucky Clover" => "banned",
    "Escape to the Wilds" => "banned",
  )

  change(
    "2022-01-25",
    "https://magic.wizards.com/en/articles/archive/news/january-25-2022-banned-and-restricted-announcement",
    "Alrund's Epiphany" => "banned",
    "Divide by Zero" => "banned",
    "Faceless Haven" => "banned",
  )

  change(
    "2022-10-10",
    "https://magic.wizards.com/en/articles/archive/news/october-10-2022-banned-and-restricted-announcement",
    "The Meathook Massacre" => "banned",
  )

  change(
    "2023-05-29",
    "https://magic.wizards.com/en/news/announcements/may-29-2023-banned-and-restricted-announcement",
    # we need to list front and back due to silly issues like partially-legal meld cards
    # (Penny Dreadful had some)
    "Fable of the Mirror-Breaker" => "banned",
    "Reflection of Kiki-Jiki" => "banned",
    "Invoke Despair" => "banned",
    "Reckoner Bankbuster" => "banned",
  )

  change(
    "2025-06-30",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-june-30-2025",
    "Cori-Steel Cutter" => "banned",
    "Abuelo's Awakening" => "banned",
    "Monstrous Rage" => "banned",
    "Heartfire Hero" => "banned",
    "Up the Beanstalk" => "banned",
    "Hopeless Nightmare" => "banned",
    "This Town Ain't Big Enough" => "banned",
  )

  change(
    "2025-11-10",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-november-10-2025",
    "Vivi Ornitier" => "banned",
    "Screaming Nemesis" => "banned",
    "Proft's Eidetic Memory" => "banned",
  )

  change(
    "2026-08-10",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-august-10-2026",
    "Badgermole Cub" => "banned",
    "Stormchaser's Talent" => "banned",
    "Gran-Gran" => "banned",
  )
end

# This banlist doesn't distinguish "suspended" from "banned"

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
end

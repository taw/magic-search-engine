BanList.for_format("pauper") do
  # No idea when Cranial Plating was banned,
  # it says in Nov 2008 that it's already banned
  format_start(
    nil,
    "Cranial Plating" => "banned",
  )

  change(
    "2011-07-01",
    # No longer available anywhere online
    "http://web.archive.org/web/20110625123730/http://community.wizards.com/magiconline/blog/2011/06/19/magic_online_br_changes_-_june_2011",
    "Frantic Search" => "banned",
  )

  change(
    "2013-02-01",
    "https://magic.wizards.com/en/articles/archive/january-28-2013-dci-banned-restricted-list-announcement-2013-01-28",
    "Empty the Warrens" => "banned",
    "Grapeshot" => "banned",
    "Invigorate" => "banned",
  )

  change(
    "2013-09-27",
    "https://magic.wizards.com/en/articles/archive/top-decks/september-27-2013-dci-banned-restricted-list-announcement-2013-09-16",
    "Cloudpost" => "banned",
    "Temporal Fissure" => "banned",
  )

  change(
    "2015-03-27",
    "https://magic.wizards.com/en/articles/archive/feature/march-23-2015-banned-and-restricted-announcement-2015-03-23",
    "Treasure Cruise" => "banned",
  )

  change(
    "2016-01-22",
    "https://magic.wizards.com/en/articles/archive/news/january-18-2016-banned-and-restricted-announcement-2016-01-18",
    "Cloud of Faeries" => "banned",
  )

  change(
    "2016-11-16",
    "http://magic.wizards.com/en/articles/archive/magic-online/pauper-banned-list-change-2016-11-03",
    "Peregrine Drake" => "banned",
  )

  change(
    "2019-05-24",
    "https://magic.wizards.com/en/articles/archive/news/may-20-2019-banned-and-restricted-announcement",
    "Gush" => "banned",
    "Gitaxian Probe" => "banned",
    "Daze" => "banned",
  )

  # No banlist date as such, but:
  # "Magic Online will implement the new format with its Core Set 2020 update
  #  and will launch new leagues with the new format starting July 2."
  change(
    "2019-07-02",
    "https://magic.wizards.com/en/articles/archive/news/pauper-comes-paper-2019-06-27",
    "Hymn to Tourach" => "banned",
    "Sinkhole" => "banned",
    "High Tide" => "banned",
  )

  change(
    "2019-10-21",
    "https://magic.wizards.com/en/articles/archive/news/october-21-2019-banned-and-restricted-announcement",
    "Arcum's Astrolabe" => "banned",
  )

  change(
    "2020-06-10",
    "https://magic.wizards.com/en/articles/archive/news/depictions-racism-magic-2020-06-10",
    "Pradesh Gypsies" => "banned",
    "Stone-Throwing Devils" => "banned",
  )

  change(
    "2020-07-13",
    "https://magic.wizards.com/en/articles/archive/news/july-13-2020-banned-and-restricted-announcement-2020-07-13",
    "Expedition Map" => "banned",
    "Mystic Sanctuary" => "banned",
  )
end

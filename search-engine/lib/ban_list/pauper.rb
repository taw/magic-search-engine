BanList.for_format("pauper") do
  # No idea when Cranial Plating was banned,
  # it says in Nov 2008 that it's already banned
  format_start(
    nil,
    "Cranial Plating" => "banned",
  )

  change(
    "2011-07-01",
    nil,
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
end

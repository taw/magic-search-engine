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
    nil,
    "Empty the Warrens" => "banned",
    "Grapeshot" => "banned",
    "Invigorate" => "banned",
  )

  change(
    "2013-09-27",
    nil,
    "Cloudpost" => "banned",
    "Temporal Fissure" => "banned",
  )

  change(
    "2015-03-27",
    nil,
    "Treasure Cruise" => "banned",
  )

  change(
    "2016-01-22",
    nil,
    "Cloud of Faeries" => "banned",
  )

  change(
    "2016-11-16",
    nil,
    "Peregrine Drake" => "banned",
  )
end

BanList.for_format("brawl") do
  # It started with Standard ban list
  format_start(
    "https://magic.wizards.com/en/articles/archive/ways-play/join-brawl-2018-03-22",
    "Smuggler's Copter" => "banned",
    "Felidar Guardian" => "banned",
    "Aetherworks Marvel" => "banned",
    "Attune with Aether" => "banned",
    "Rogue Refiner" => "banned",
    "Rampaging Ferocidon" => "banned",
    "Ramunap Ruins" => "banned",
  )

  # Got own ban list, so 6/7 Standard cards unbanned (Smuggler's Copter remained), 2 new bans
  change(
    "2018-05-10",
    "https://magic.wizards.com/en/articles/archive/news/future-brawl-2018-05-10",
    "Felidar Guardian" => "legal",
    "Aetherworks Marvel" => "legal",
    "Attune with Aether" => "legal",
    "Rogue Refiner" => "legal",
    "Rampaging Ferocidon" => "legal",
    "Ramunap Ruins" => "legal",
    "Baral, Chief of Compliance" => "banned",
    "Sorcerous Spyglass" => "banned",
  )

  change(
    "2019-11-18",
    "https://magic.wizards.com/en/articles/archive/news/november-18-2019-banned-and-restricted-announcement",
    "Oko, Thief of Crowns" => "banned",
  )

  change(
    "2020-03-10",
    "https://magic.wizards.com/en/articles/archive/news/march-9-2020-banned-and-restricted-announcement",
    "Golos, Tireless Pilgrim" => "banned",
  )

  change(
    "2020-04-16",
    "https://magic.wizards.com/en/articles/archive/news/april-13-2020-banned-and-restricted-announcement",
    "Lutri, the Spellchaser" => "banned",
  )

  change(
    "2020-05-18",
    "https://magic.wizards.com/en/articles/archive/news/may-18-2020-banned-and-restricted-announcement",
    "Drannith Magistrate" => "banned",
    "Winota, Joiner of Forces" => "banned",
  )
end

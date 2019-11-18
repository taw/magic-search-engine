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
end

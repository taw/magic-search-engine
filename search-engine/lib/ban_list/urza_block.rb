BanList.for_format("urza block") do
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
    "Time Spiral" => "banned",
    "Windfall" => "banned",
  )

  change(
    "1999-07-01",
    "http://web.archive.org/web/20111121212434/http://www.crystalkeep.com/magic/rules/dci/update-990601.txt",
    "Gaea's Cradle" => "banned",
    "Serra's Sanctum" => "banned",
    "Tolarian Academy" => "banned",
    "Voltaic Key" => "banned",
  )
end

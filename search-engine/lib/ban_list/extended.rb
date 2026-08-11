# Format isn't even supported so sort of pointless
BanList.for_format("extended") do
  # Braingeyser is here because the December 1, 1998 announcement below unbans it, and the
  # three ante/dexterity cards because the DCI's own Extended list (the source below) has
  # them banned. When any of them went on the list is not recorded.
  format_start(
    "https://web.archive.org/web/20000511092139/http://www.wizards.com/dci/judge/resources/sfr_extended.asp",
    "Amulet of Quoz" => "banned",
    "Braingeyser" => "banned",
    "Timmerian Fiends" => "banned",
    "Zuran Orb" => "banned",
  )

  change(
    "1997-10-01",
    nil,
    "Hypnotic Specter" => "banned",
  )

  change(
    "1998-07-01",
    "https://web.archive.org/web/19981205023409/http://www.wizards.com/DCI/BR6-1-98.html",
    "Land Tax" => "banned",
  )

  change(
    "1999-01-01",
    "https://web.archive.org/web/19990209004446/http://www.wizards.com/DCI/MTG_DCI_BR12-1-98.html",
    "Braingeyser" => "legal",
    "Tolarian Academy" => "banned",
    "Windfall" => "banned",
  )

  # Emergency announcement. Its page was already a 404 when the Wayback Machine first
  # visited, so only the date survives, from the DCI announcement archive index. The
  # March 1, 1999 announcement explicitly says "No changes" for Extended.
  change(
    "1999-03-11",
    "https://web.archive.org/web/20010128184200/http://www.wizards.com/DCI/announce_archive.asp",
    "Memory Jar" => "banned",
  )

  change(
    "1999-07-01",
    "http://web.archive.org/web/20111121212434/http://www.crystalkeep.com/magic/rules/dci/update-990601.txt",
    "Time Spiral" => "banned",
  )

  change(
    "1999-08-01",
    "https://web.archive.org/web/20000422065433/http://www.wizards.com/DCI/announce.asp?dci19990716a",
    "Yawgmoth's Bargain" => "banned",
  )

  change(
    "1999-10-01",
    "https://web.archive.org/web/20000305053359/http://www.wizards.com/DCI/announce.asp?dci19990901b",
    "Dream Halls" => "banned",
    "Earthcraft" => "banned",
    "Lotus Petal" => "banned",
    "Mind Over Matter" => "banned",
    "Yawgmoth's Will" => "banned",
  )

  change(
    "2000-04-01",
    "https://web.archive.org/web/20000510094853/http://www.wizards.com/dci/judge/resources/br_030100.asp",
    "Dark Ritual" => "banned",
    "Mana Vault" => "banned",
  )

  change(
    "2001-04-01",
    nil,
    "Demonic Consultation" => "banned",
    "Necropotence" => "banned",
    "Replenish" => "banned",
    "Survival of the Fittest" => "banned",
  )

  change(
    "2003-10-01",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20030901a",
    "Entomb" => "banned",
    "Frantic Search" => "banned",
    "Goblin Lackey" => "banned",
  )

  change(
    "2004-01-01",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20031201a",
    "Ancient Tomb" => "banned",
    "Goblin Recruiter" => "banned",
    "Grim Monolith" => "banned",
    "Hermit Druid" => "banned",
    "Oath of Druids" => "banned",
    "Tinker" => "banned",
  )

  change(
    "2004-09-20",
    "http://www.wizards.com/Default.asp?x=dci/announce/dci20040901a",
    "Metalworker" => "banned",
    "Skullclamp" => "banned",
  )

  change(
    "2005-09-20",
    "http://www.wizards.com/default.asp?x=dci/announce/dci20050901a",
    "Aether Vial" => "banned",
    "Disciple of the Vault" => "banned",
  )

  change(
    "2008-09-20",
    "https://magic.wizards.com/en/articles/archive/feature/september-1-2008-dci-banned-and-restricted-list-announcement-2008-09-01",
    "Sensei's Divining Top" => "banned",
  )

  change(
    "2010-07-01",
    "https://magic.wizards.com/en/articles/archive/magic-online/june-18-2010-dci-banned-restricted-list-announcement-2010-06-18",
    "Hypergenesis" => "banned",
    "Sword of the Meek" => "banned",
  )

  change(
    "2011-10-01",
    "https://magic.wizards.com/en/articles/archive/feature/september-20-2011-dci-banned-restricted-list-announcement-2011-09-20",
    "Jace, the Mind Sculptor" => "banned",
    "Mental Misstep" => "banned",
    "Ponder" => "banned",
    "Preordain" => "banned",
    "Stoneforge Mystic" => "banned",
  )
end

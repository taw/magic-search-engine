# The ranked Brawl queue. Same card pool and same deck construction as Brawl - the only
# difference the search engine can see is the ban list, and the two lists are built on
# opposite principles: Brawl bans cards in the 99 that are unfun to play against and
# leaves commanders to matchmaking, Competitive Brawl bans nothing but overpowered
# commanders. Neither list is a subset of the other.
#
# It was announced as "Ranked Brawl" and renamed a week later, because players read the
# old name as promising a shared ban list.
# https://magic.wizards.com/en/news/mtg-arena/introducing-ranked-brawl
class FormatCompetitiveBrawl < FormatBrawl
  def format_pretty_name
    "Competitive Brawl"
  end

  def format_start_date
    "2026-06-23"
  end
end

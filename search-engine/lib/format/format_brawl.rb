# Arena's main Brawl queue. It launched as "Historic Brawl", and was renamed to plain
# "Brawl" in the 2023.33.00 client update once its card pool had drifted away from
# Historic's - it uses everything on Arena, where Historic pre-bans a lot of it.
# WotC's banned list page and mtgjson both call this one "Brawl", and Standard Brawl
# (which held the name first) is the one that needs qualifying now.
class FormatBrawl < FormatHistoric
  include BrawlDeckRules

  def format_pretty_name
    "Brawl"
  end

  # https://magic.wizards.com/en/news/mtg-arena/historic-brawl-2020-12-21
  def format_start_date
    "2020-12-21"
  end

  # 60 cards at launch, 100 from 2021-06-19. Not worth modelling - the deck checker has
  # no way to say "this deck was legal five years ago".
  # https://magic.wizards.com/en/articles/archive/magic-digital/mtg-arena-announcements-june-16-2021
  def deck_size
    100
  end
end

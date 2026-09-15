class FormatTimeless < FormatHistoric
  def format_pretty_name
    "Timeless"
  end

  # Announced 2023-12-04, live on Arena together with the digital release of
  # Khans of Tarkir - the fetch lands are what the format was created for.
  # https://magic.wizards.com/en/news/mtg-arena/introducing-timeless-a-new-mtg-arena-format
  def format_start_date
    "2023-12-12"
  end

  # The card pool is exactly Historic's - everything on Arena - so in_format? is
  # inherited. The two formats used to disagree about rebalanced cards, Historic
  # playing the A- version of a paper card and Timeless the original, but Arena
  # reverted every one of those on 2026-09-22 and there is nothing left to
  # disagree about. Only the ban lists differ now.
end

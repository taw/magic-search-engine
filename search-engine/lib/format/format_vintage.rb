class FormatVintage < Format
  def format_pretty_name
    "Vintage"
  end

  def build_excluded_sets
    # Sets not in Vintage at all (except for basic lands):
    # * Celebration
    # * Unglued
    # * Unhinged
    # * Happy Holidays
    #
    # Promos which mix legal and uncards, so need to be excluded:
    # * Arena League
    # * Release Events
    #
    # Excluded due to mix of bad timestamps (which confuses tests and time travel):
    # * Resale Promos

    excluded_sets = Set[
      "ana",
      "cmb1",
      "h17",
      "hho",
      "htr",
      "htr17",
      "htr18",
      "j17",
      "pal04",
      "parl",
      "pcel",
      "ppc1",
      "prel",
      "pres",
      "prm",
      "ptg",
      "pust",
      "tbth",
      "tdag",
      "tfth",
      "thp1",
      "thp2",
      "thp3",
      "ugl",
      "und",
      "unh",
      "ust",
      "wc97",
      "wc98",
      "wc99",
      "wc99",
      "wc00",
      "wc01",
      "wc02",
      "wc03",
      "wc04",
    ]

    # Portal / Starter sets used to not be tournament legal
    if @time and @time < Date.parse("2005.3.20")
      excluded_sets += Set["ppod", "por", "p02", "ptk", "s99", "s00"]
    end

    excluded_sets
  end
end

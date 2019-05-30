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

    excluded_sets = Set["parl", "pcel", "ugl", "prel", "unh", "hho", "ust", "pust", "ppc1"]

    # Portal / Starter sets used to not be tournament legal
    if @time and @time < Date.parse("2005.3.20")
      excluded_sets += Set["ppod", "por", "p02", "ptk", "s99", "s00"]
    end

    excluded_sets
  end
end

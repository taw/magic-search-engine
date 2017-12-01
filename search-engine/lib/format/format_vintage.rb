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

    excluded_sets = Set["arena", "uqc", "ug", "rep", "uh", "hho", "ust"]

    # Portal / Starter sets used to not be tournament legal
    if @time and @time < Date.parse("2005.3.20")
      excluded_sets += Set["pot", "po", "po2", "p3k", "st", "st2k"]
    end

    excluded_sets
  end
end

class FormatVintage < Format
  def format_pretty_name
    "Vintage"
  end

  def build_excluded_sets
    # Most exclusions are covered by is:funny
    #
    # This only needs to list ones that are not, like:
    # * sets which exist only on Arena
    # * sets which exist only in other digital games (Shandalar or Sega)
    # * token Dungeon sets (this is somewhat questionable if they should be included or not)
    #
    # This could be done programatically instead

    excluded_sets = Set[*%w[
      ana
      anb
      hbg
      j21
      oana
      past
      pmic
      prm
      psdg
      tafr
      tclb
      xana
      ybro
      ydmu
      ymid
      yneo
      yone
      ysnc
    ]]

    # Portal / Starter sets used to not be tournament legal
    if @time and @time < Date.parse("2005.3.20")
      excluded_sets += Set["por", "p02", "ptk", "s99", "s00"]
    end

    excluded_sets
  end
end

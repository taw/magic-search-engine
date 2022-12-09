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
    #
    # Sets which exist only on Arena

    excluded_sets = Set[*%w[
      ana
      anb
      cmb1
      cmb2
      h17
      hbg
      hho
      htr
      htr16
      htr17
      htr18
      htr19
      htr20
      j17
      j21
      o90p
      oana
      olep
      p30a
      pal04
      parl
      past
      pcel
      ph17
      ph18
      ph19
      ph20
      ph21
      phtr
      plist
      pmic
      ppc1
      prel
      pres
      prm
      psdg
      ptg
      punh
      pust
      sunf
      tafr
      tbth
      tclb
      tdag
      tfth
      thp1
      thp2
      thp3
      ugl
      und
      unh
      uplist
      ust
      wc00
      wc01
      wc02
      wc03
      wc04
      wc97
      wc98
      wc99
      wc99
      xana
      ydmu
      ymid
      yneo
      ysnc
    ]]

    # Portal / Starter sets used to not be tournament legal
    if @time and @time < Date.parse("2005.3.20")
      excluded_sets += Set["por", "p02", "ptk", "s99", "s00"]
    end

    excluded_sets
  end
end

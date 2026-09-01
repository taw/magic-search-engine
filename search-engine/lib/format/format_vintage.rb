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
    # This could be done programmatically instead
    #
    # Pauper format needs it for defining what counts as a "common"
    #
    # SLZ excluded from Pauper legality https://bsky.app/profile/gavinverhey.bsky.social/post/3mtu55rdm4c2f
    # (it's here because it's just reprints and doesn't affect any other format)

    excluded_sets = Set[*%w[
      30a
      aa1
      aa2
      aa3
      aa4
      ana
      anb
      hbg
      j21
      oana
      om1
      omb
      past
      pf26
      pio
      pmic
      prm
      psdg
      purl
      pw26
      ren
      rin
      sir
      sis
      slz
      tafr
      tclb
      tltr
      xana
      yblb
      ybro
      ydft
      ydmu
      ydsk
      yeoe
      ylci
      ymid
      ymkm
      yneo
      yone
      yotj
      ysnc
      ytdm
      ywoe
      yecl
      ysos
    ]]

    # Portal / Starter sets used to not be tournament legal
    if @time and @time < Date.parse("2005.3.20")
      excluded_sets += Set["por", "p02", "ptk", "s99", "s00"]
    end

    excluded_sets
  end
end

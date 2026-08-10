class FormatPremodern < Format
  def format_pretty_name
    "Premodern"
  end

  # No format_start_date - the format has no start announcement to point at.
  # It's community-created, and the only date its own site ever gives is the year:
  # "Premodern was invented in 2012 by Martin Berlin", played casually in Stockholm for years
  # before the website and the ban list went up (site's first archived snapshot is 2018-05).
  # https://web.archive.org/web/20180506042814/http://premodernmagic.com/about

  def build_included_sets
    Set[
      "4ed", # Fourth Edition
      "ice", # Ice Age
      "chr", # Chronicle
      "hml", # Homelands
      "all", # Alliances
      "mir", # Mirage
      "vis", # Visions
      "5ed", # Fifth Edition
      "wth", # Weatherlight
      "tmp", # Tempest
      "sth", # Stronghold
      "exo", # Exodus
      "usg", # Urza's Saga
      "ulg", # Urza's Legacy
      "6ed", # Classic Sixth Edition
      "uds", # Urza's Destiny
      "mmq", # Mercadian Masques
      "nem", # Nemesis
      "pcy", # Prophecy
      "inv", # Invasion
      "pls", # Planeshift
      "7ed", # Seventh Edition
      "apc", # Apocalypse
      "ody", # Odyssey
      "tor", # Torment
      "jud", # Judgment
      "ons", # Onslaught
      "lgn", # Legions
      "scg", # Scourge
    ]
  end
end

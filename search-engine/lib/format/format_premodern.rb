class FormatPremodern < Format
  def format_pretty_name
    "Premodern"
  end

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

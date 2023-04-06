class FormatFrontier < Format
  def format_pretty_name
    "Frontier"
  end

  def build_included_sets
    Set[
      "m15",
      "ktk", "frf", "dtk",
      "ori",
      "bfz", "ogw",
      "soi", "w16", "emn",
      "kld", "aer",
      "akh", "w17", "hou",
      "xln", "rix",
      "dom",
      "m19", "g18",
      "grn", "rna", "war",
      "m20",
      "eld",
      "thb",
      "iko",
      "m21",
      "znr",
      "khm",
      "stx",
      "afr",
      "mid",
      "vow",
      "neo",
      "snc",
      "dmu",
      "bro",
      "one",
      "mom",
    ]
  end
end

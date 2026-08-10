class FormatPioneer < Format
  def format_pretty_name
    "Pioneer"
  end

  # Announcement day, which also published the initial ban list (the five fetchlands).
  # Magic Online support followed on 2019-10-23.
  # https://magic.wizards.com/en/articles/archive/news/announcing-pioneer-format-2019-10-21
  def format_start_date
    "2019-10-21"
  end

  def build_included_sets
    Set[
      "rtr", "gtc", "dgm",
      "m14",
      "ths", "bng", "jou",
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
      "mat",
      "woe",
      "lci",
      "mkm",
      "otj",
      "big",
      "blb",
      "dsk",
      "fdn",
      "dft",
      "tdm",
      "fin",
      "eoe",
      "spm",
      "tla",
      "ecl",
      "tmt",
      "sos",
      "msh",
    ]
  end
end

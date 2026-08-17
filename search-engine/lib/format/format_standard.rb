require "date"

class FormatStandard < Format
  # Newest first, so the rotation in effect is the first one that already happened
  def build_included_sets
    rotation_sets rotations.find{|rotation_time, _| rotation_time <= rotation_reference_time}
  end

  def format_pretty_name
    "Standard"
  end

  # Schedule also contains rotations which didn't happen yet, so FormatFuture can use them.
  # They're relative to the time we traveled to, or to today if we're not time traveling.
  def rotation_reference_time
    @time || Date.today
  end

  # Subclasses with their own schedule (Alchemy) define their own constant;
  # the ones without (Future, Brawl) inherit Standard's through the ancestors.
  def rotations
    self.class::ROTATION_SCHEDULE
  end

  def rotation_sets(rotation)
    rotation ? rotation.last.to_set : Set[]
  end

  def display_rotation_schedule?
    true
  end

  # Rotation history for display, most recent rotation first, as [end_date, sets] pairs.
  # Sets within each rotation are in rotation_schedule order, which is release date order.
  # Rotations which didn't happen yet are not included, and the current card pool has no
  # end date, as the next rotation date is never definite.
  # ROTATION_SCHEDULE is newest first already, and select keeps that order.
  def rotation_history(db)
    past_rotations = rotations.select{|rotation_time, _| rotation_time <= rotation_reference_time}
    end_times = [nil, *past_rotations.map(&:first)]
    past_rotations.zip(end_times).map do |(_, set_codes), end_time|
      [end_time, set_codes.map{|set_code| db.sets[set_code]}.compact]
    end
  end

  # http://archive.wizards.com/Magic/magazine/article.aspx?x=mtg/daily/feature/27a
  # for change in core set rotation - "Core sets will rotate as if they were part of the block preceding them."
  #
  # http://archive.wizards.com/magic/magazine/Article.aspx?x=mtgcom/feature/291
  # says Coldsnap rotates out with Time Spiral block
  #
  # Dates are parsed once here rather than on every Format instantiation. A card
  # page builds all 39 formats to work out its legalities, and re-parsing this
  # schedule (twice, as FormatFuture inherits it) was most of what that cost.
  ROTATION_SCHEDULE = {
    # Rotation moves to the first premier set of the calendar year, so 2026 gets no rotation at all,
    # and the next one happens with Nauctis: The Sunken Realm, so Standard becomes 2025+2026+2027 sets.
    # https://magic.wizards.com/en/news/announcements/everything-announced-for-the-magic-multiverse-in-2027
    # Sets released in 2027 will be added here as they come out.
    # This rotation didn't happen yet, only f:future looks at it.
    "2027-02-05" => ["fdn", "dft", "tdm", "fin", "eoe", "spm", "tla", "ecl", "tmt", "sos", "msh", "hob", "fra", "trk"],
    "2025-07-29" => ["woe", "lci", "mkm", "otj", "big", "blb", "dsk", "fdn", "dft", "tdm", "fin", "eoe", "spm", "tla", "ecl", "tmt", "sos", "msh", "hob"],
    # FDN has special rotation
    "2024-08-02" => ["dmu", "bro", "one", "mom", "mat", "woe", "lci", "mkm", "otj", "big", "blb", "dsk", "fdn", "dft", "tdm", "fin"],
    # Standard changed so sets last 3 years so 2023 rotation skipped
    "2022-09-09" => ["mid", "vow", "neo", "snc", "dmu", "bro", "one", "mom", "mat", "woe", "lci", "mkm", "otj", "big"],
    # 4 blocks system, 1 rotation/year
    "2021-09-18" => ["znr", "khm", "stx", "afr", "mid", "vow", "neo", "snc"],
    "2020-09-25" => ["eld", "thb", "iko", "m21", "znr", "khm", "stx", "afr"],
    "2019-10-04" => ["grn", "rna", "war", "m20", "eld", "thb", "iko", "m21"],
    "2018-10-05" => ["xln", "rix", "dom", "m19", "grn", "g18", "rna", "war", "m20"],
    "2017-09-29" => ["kld", "aer", "w17", "akh", "hou", "xln", "rix", "dom", "m19", "g18"],
    "2016-09-30" => ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "w17", "akh", "hou"],
    # 3 blocks system, 2 rotations/year
    # w16 was released together with soi
    "2016-04-08" => ["dtk", "ori", "bfz", "ogw", "soi", "w16", "emn"],         # soi
    "2015-10-02" => ["ktk", "frf", "dtk", "ori", "bfz", "ogw"],                # bfz
    # 2 blocks system, 1 rotation/year
    "2014-09-26" => ["ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori"],  # ktk
    "2013-09-27" => ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15"],  # ths
    "2012-10-05" => ["isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14"],  # rtr
    "2011-09-30" => ["som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13"],  # isd
    "2010-10-01" => ["zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12"],  # som
    "2009-10-02" => ["ala", "con", "arb", "m10", "zen", "wwk", "roe", "m11"],  # zen
    # 2 blocks + 1 core system
    "2009-07-17" => ["lrw", "mor", "shm", "eve", "ala", "con", "arb", "m10"], # m10
    "2008-10-03" => ["10e", "lrw", "mor", "shm", "eve", "ala", "con", "arb"], # ala
    "2007-10-12" => ["csp", "tsp", "tsb", "plc", "fut", "10e", "lrw", "mor", "shm", "eve"], # lrw
    "2007-07-13" => ["rav", "gpt", "dis", "csp", "tsp", "tsb", "plc", "fut", "10e"], # 10e
    "2006-10-06" => ["9ed", "rav", "gpt", "dis", "csp", "tsp", "tsb", "plc", "fut"], # tsp
    "2005-10-07" => ["chk", "bok", "sok", "9ed", "rav", "gpt", "dis", "csp"], # rav
    "2005-07-29" => ["mrd", "dst", "5dn", "chk", "bok", "sok", "9ed"], # 9ed
    "2004-10-01" => ["8ed", "mrd", "dst", "5dn", "chk", "bok", "sok"], # chk
    "2003-10-02" => ["ons", "lgn", "scg", "8ed", "mrd", "dst", "5dn"], # mrd
    "2003-07-28" => ["ody", "tor", "jud", "ons", "lgn", "scg", "8ed"], # 8ed
    "2002-10-07" => ["7ed", "ody", "tor", "jud", "ons", "lgn", "scg"], # ons
    "2001-10-01" => ["inv", "pls", "7ed", "apc", "ody", "tor", "jud"], # ody
    "2001-04-11" => ["mmq", "nem", "pcy", "inv", "pls", "7ed", "apc"], # 7ed
    "2000-10-02" => ["6ed", "mmq", "nem", "pcy", "inv", "pls"], # inv
    "1999-10-04" => ["usg", "ulg", "6ed", "uds", "mmq", "nem", "pcy"], # mmq
    "1999-04-21" => ["tmp", "sth", "exo", "usg", "ulg", "6ed", "uds"], # 6ed
    "1998-10-12" => ["5ed", "tmp", "sth", "exo", "usg", "ulg"], # usg
    "1997-10-14" => ["mir", "vis", "5ed", "wth", "tmp", "sth", "exo"], # tmp
    # Legality rules before this point changed regularly
    # and did not follow established rotation schedule
    # basing it on https://mtg.fandom.com/wiki/Standard/Timeline
    "1997-07-01" => ["ice", "hml", "all", "mir", "vis", "5ed", "wth"],
    "1997-04-23" => ["chr", "all", "mir", "vis", "5ed"],
    "1997-03-05" => ["4ed", "chr", "all", "mir", "vis"],
    "1997-01-01" => ["4ed", "chr", "hml", "all", "mir"],
    "1996-10-01" => ["fem", "4ed", "ice", "chr", "hml", "all", "mir"],
    "1996-06-01" => ["fem", "4ed", "ice", "chr", "hml", "all"],
    "1995-10-01" => ["fem", "4ed", "ice", "chr", "hml"],
    "1995-08-01" => ["fem", "4ed", "ice", "chr"],
    "1995-06-01" => ["fem", "4ed", "ice"],
    "1995-04-19" => ["drk", "fem", "4ed"],
    "1995-01-10" => ["3ed", "drk", "fem"], # standard officially announced, no standard before
  }.map{|rotation_time, rotation_sets| [Date.parse(rotation_time), rotation_sets.freeze].freeze}.freeze
end

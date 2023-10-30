class FormatStandard < Format
  def build_included_sets
    last_rotation = rotation_schedule.map do |rotation_time, rotation_sets|
      rotation_time = Date.parse(rotation_time)
      if !@time or @time >= rotation_time
        [rotation_time, rotation_sets]
      else
        nil
      end
    end.compact.max_by(&:first)
    if last_rotation
      last_rotation.last.to_set
    else
      Set[]
    end
  end

  def format_pretty_name
    "Standard"
  end

  def rotation_schedule
    # http://archive.wizards.com/Magic/magazine/article.aspx?x=mtg/daily/feature/27a
    # for change in core set rotation - "Core sets will rotate as if they were part of the block preceding them."
    #
    # http://archive.wizards.com/magic/magazine/Article.aspx?x=mtgcom/feature/291
    # says Coldsnap rotates out with Time Spiral block

    {
      # Standard changed so sets last 3 years so 2023 rotation skipped
      "2022-09-09" => ["mid", "vow", "neo", "snc", "dmu", "bro", "one", "mom", "mat", "woe", "lci"],
      # 4 blocks system, 1 rotation/year
      "2021-09-18" => ["znr", "khm", "stx", "afr", "mid", "vow", "neo", "snc"],
      "2020-09-25" => ["eld", "thb", "iko", "m21", "znr", "khm", "stx", "afr"],
      "2019-10-04" => ["grn", "rna", "war", "m20", "eld", "thb", "iko", "m21"],
      "2018-10-05" => ["xln", "rix", "dom", "m19", "g18", "grn", "rna", "war", "m20"],
      "2017-09-29" => ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom", "m19", "g18"],
      "2016-09-30" => ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17", "hou"],
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
    }
  end
end

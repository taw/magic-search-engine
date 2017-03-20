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

    # ["al", "be", "an", "un", "aq", "rv", "lg", "dk", "fe", "4e", "ia", "hl", "ai", "mr", "vi", "5e", "wl", "tp", "sh", "ex", "us", "ul", "6e", "ud", "mm", "ne", "pr", "in", "ps", "7e", "ap", "od", "tr", "ju", "on", "le", "sc", "8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10"]
    {
      # 4 blocks system, 1 rotation/year
      # w16 was released together with soi
      # next rotation:
      # "Q4 2017"    => ["kld", "aer"], "kld", "aer"], # + Amonkhet, Hour of Devastation
      "2016-09-30" => ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer"], # + Amonkhet, Hour of Devastation
      # 3 blocks system, 2 rotations/year
      "2016-04-08" => ["dtk", "ori", "bfz", "ogw", "soi", "w16", "emn"],         # soi
      "2015-10-02" => ["ktk", "frf", "dtk", "ori", "bfz", "ogw"],                # bfz
      # 2 blocks system, 1 rotation/year
      "2014-09-26" => ["ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori"],  # ktk
      "2013-09-27" => ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15"],  # ths
      "2012-10-05" => ["isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14"],  # rtr
      "2011-09-30" => ["som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13"],  # isd
      "2010-10-01" => ["zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12"],  # som
      "2009-10-02" => ["ala", "cfx", "arb", "m10", "zen", "wwk", "roe", "m11"],  # zen
      # 2 blocks + 1 core system
      "2009-07-17" => ["lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10"], # m10
      "2008-10-03" => ["10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb"], # ala
      "2007-10-12"  => ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve"], # lw
      "2007-07-13" => ["rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e"], # 10e
      "2006-10-06" => ["9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut"], # ts
      "2005-10-07" => ["chk", "bok", "sok", "9e", "rav", "gp", "di", "cs"], # rav
      "2005-07-29" => ["mi", "ds", "5dn", "chk", "bok", "sok", "9e"], # 9e
      "2004-10-01" => ["8e", "mi", "ds", "5dn", "chk", "bok", "sok"], # chk
      "2003-10-02" => ["on", "le", "sc", "8e", "mi", "ds", "5dn"], # mi
      "2003-07-28" => ["od", "tr", "ju", "on", "le", "sc", "8e"], # 8e
      "2002-10-07" => ["7e", "od", "tr", "ju", "on", "le", "sc"], # on
      "2001-10-01" => ["in", "ps", "7e", "ap", "od", "tr", "ju"], # od
      "2001-04-11" => ["mm", "ne", "pr", "in", "ps", "7e", "ap"], # 7e
      "2000-10-02" => ["6e", "mm", "ne", "pr", "in", "ps"], # in
      "1999-10-04" => ["us", "ul", "6e", "ud", "mm", "ne", "pr"], # mm
      "1999-04-21" => ["tp", "sh", "ex", "us", "ul", "6e", "ud"], # 6e
      "1998-10-12" => ["5e", "tp", "sh", "ex", "us", "ul"], # us
      "1997-10-14" => ["mr", "vi", "5e", "wl", "tp", "sh", "ex"], # tp
    }
  end
end

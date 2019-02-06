class FormatECH < FormatStandard
  def format_pretty_name
    "Elder Cockatrice Highlander"
  end

  def include_custom_sets?
    true
  end

  def rotation_schedule
    {
      "2018-01-12" => ["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "net", "cc18"],
      "2018-01-16" => ["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "net", "cc18", "ech"],
      "2018-01-21" => ["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "net", "cc18", "ech", "hlw"],
      "2018-08-30" => ["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "cc18", "hlw", "vst", "dhm", "rak"],
      "2018-10-25" => ["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "cc18", "hlw", "vst", "dhm", "rak", "net"],
      "2019-02-08" => ["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "cc18", "hlw", "vst", "dhm", "rak", "net", "eau"]
    }
  end
end

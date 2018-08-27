class FormatECH < Format
  def format_pretty_name
    "Elder Cockatrice Highlander"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    #TODO NET was part of the format from start until August/September 2018 format changes
    #TODO CC18 was part of the format since the start (adjust other formats accordingly)
    #TODO ECH (Ancient Elemental) was part of the format from 2018-01-09 until August/September 2018 format changes
    Set["ayr", "dms", "ank", "ldo", "tsl", "vln", "jan", "hlw", "cc18", "vst", "dhm", "rak"]
  end
end

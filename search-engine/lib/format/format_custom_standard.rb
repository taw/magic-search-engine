class FormatCustomStandard < FormatStandard
  def format_pretty_name
    "Custom Standard"
  end

  def include_custom_sets?
    true
  end

  def rotation_schedule
    {
      "2016-12-08" => ["ayr", "dms", "ank"],
      "2017-04-21" => ["ayr", "dms", "ank", "ldo", "tsl"],
      "2017-08-06" => ["dms", "ank", "ldo", "tsl", "vln"],
      "2017-11-05" => ["dms", "ldo", "tsl", "vln", "jan"]
    }
  end
end

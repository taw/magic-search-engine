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
      "2017-12-21" => ["ayr", "dms", "ank", "ldo", "tsl"]
    }
  end
end

class FormatCustomEternal < Format
  def format_pretty_name
    "Custom Eternal"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    Set["ayr", "dms", "ank", "ldo", "tsl", "vln"]
  end
end

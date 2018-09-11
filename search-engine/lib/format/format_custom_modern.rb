class FormatCustomModern < Format
  def format_pretty_name
    "Custom Modern"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    Set["ldo", "tsl", "vln", "jan", "hlw", "cc18"]
  end
end

class FormatCustomModern < Format
  def format_pretty_name
    "Custom Modern"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    Format["custom eternal"].new(@time).build_included_sets - Set["ayr", "dms", "ank"]
  end
end

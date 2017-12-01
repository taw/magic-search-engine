class FormatUnsets < Format
  def format_pretty_name
    "Unsets"
  end

  def build_included_sets
    Set["ug", "uh", "ust"]
  end
end

class FormatUnsets < Format
  def format_pretty_name
    "Unsets"
  end

  def build_format_sets
    Set["ug", "uh"]
  end
end

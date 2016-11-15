class FormatUnknown < Format
  def format_pretty_name
    "Unknown"
  end

  def build_included_sets
    Set[]
  end
end

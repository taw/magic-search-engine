class FormatIceAgeBlock < Format
  def format_pretty_name
    "Ice Age Block"
  end

  def build_included_sets
    Set["ice", "all", "csp"]
  end
end


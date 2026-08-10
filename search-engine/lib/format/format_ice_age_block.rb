class FormatIceAgeBlock < Format
  def format_pretty_name
    "Ice Age Block"
  end

  def format_start_date
    "1995-06-03"
  end

  def build_included_sets
    Set["ice", "all", "csp"]
  end
end


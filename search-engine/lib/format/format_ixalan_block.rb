class FormatIxalanBlock < Format
  def format_pretty_name
    "Ixalan Block"
  end

  def format_start_date
    "2017-09-29"
  end

  def build_included_sets
    Set["xln", "rix"]
  end
end

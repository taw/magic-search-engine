class FormatTarkirBlock < Format
  def format_pretty_name
    "Tarkir Block"
  end

  def format_start_date
    "2014-09-26"
  end

  def build_included_sets
    Set["ktk", "frf", "dtk"]
  end
end

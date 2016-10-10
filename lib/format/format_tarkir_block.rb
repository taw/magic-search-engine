class FormatTarkirBlock < Format
  def format_pretty_name
    "Tarkir Block"
  end

  def build_format_sets
    Set["ktk", "frf", "dtk"]
  end
end

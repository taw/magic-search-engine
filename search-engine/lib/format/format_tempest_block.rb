class FormatTempestBlock < Format
  def format_pretty_name
    "Tempest Block"
  end

  def format_start_date
    "1997-10-14"
  end

  def build_included_sets
    Set["tmp", "sth", "exo"]
  end
end

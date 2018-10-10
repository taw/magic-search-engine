class FormatTempestBlock < Format
  def format_pretty_name
    "Tempest Block"
  end

  def build_included_sets
    Set["tmp", "sth", "exo"]
  end
end

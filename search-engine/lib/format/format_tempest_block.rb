class FormatTempestBlock < Format
  def format_pretty_name
    "Tempest Block"
  end

  def build_included_sets
    Set["tp", "sh", "ex"]
  end
end

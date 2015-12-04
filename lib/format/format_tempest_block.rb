class FormatTempestBlock < Format
  def format_pretty_name
    "Tempest Block"
  end

  def format_sets
    Set["tp", "sh", "ex"]
  end
end

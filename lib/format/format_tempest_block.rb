class FormatTempestBlock < Format
  def format_name
    "tempest block"
  end

  def format_sets
    Set["tp", "sh", "ex"]
  end
end

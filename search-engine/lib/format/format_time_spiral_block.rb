class FormatTimeSpiralBlock < Format
  def format_pretty_name
    "Time Spiral Block"
  end

  def build_included_sets
    Set["tsp", "tsb", "plc", "fut"]
  end
end

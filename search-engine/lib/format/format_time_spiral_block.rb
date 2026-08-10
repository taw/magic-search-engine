class FormatTimeSpiralBlock < Format
  def format_pretty_name
    "Time Spiral Block"
  end

  def format_start_date
    "2006-10-06"
  end

  def build_included_sets
    Set["tsp", "tsb", "plc", "fut"]
  end
end

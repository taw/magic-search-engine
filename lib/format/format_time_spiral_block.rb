class FormatTimeSpiralBlock < Format
  def format_name
    "time spiral block"
  end

  def format_sets
    Set["ts", "tsts", "pc", "fut"]
  end
end

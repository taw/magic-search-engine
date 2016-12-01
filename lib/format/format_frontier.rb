class FormatFrontier < Format
  def format_pretty_name
    "Frontier"
  end

  def build_included_sets
    Set["m15", "ktk", "frf", "dtk", "ori", "bfz", "ogw", "soi", "emn", "kld"]
  end
end

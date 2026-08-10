class FormatLorwynBlock < Format
  def format_pretty_name
    "Lorwyn Block"
  end

  def format_start_date
    "2007-10-12"
  end

  def build_included_sets
    Set["lrw", "mor", "shm", "eve"]
  end
end

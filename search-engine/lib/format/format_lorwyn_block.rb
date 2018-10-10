class FormatLorwynBlock < Format
  def format_pretty_name
    "Lorwyn Block"
  end

  def build_included_sets
    Set["lrw", "mor", "shm", "eve"]
  end
end

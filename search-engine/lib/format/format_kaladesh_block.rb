class FormatKaladeshBlock < Format
  def format_pretty_name
    "Kaladesh Block"
  end

  def format_start_date
    "2016-09-30"
  end

  def build_included_sets
    Set["kld", "aer"]
  end
end

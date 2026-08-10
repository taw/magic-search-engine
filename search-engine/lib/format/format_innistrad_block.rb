class FormatInnistradBlock < Format
  def format_pretty_name
    "Innistrad Block"
  end

  def format_start_date
    "2011-09-30"
  end

  def build_included_sets
    Set["isd", "dka", "avr"]
  end
end

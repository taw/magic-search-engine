class FormatInnistradBlock < Format
  def format_pretty_name
    "Innistrad Block"
  end

  def format_sets
    Set["isd", "dka", "avr"]
  end
end

class FormatInnistradBlock < Format
  def format_name
    "innistrad block"
  end

  def format_sets
    Set["isd", "dka", "avr"]
  end
end

class FormatRavnicaBlock < Format
  def format_pretty_name
    "Ravnica Block"
  end

  def format_start_date
    "2005-10-07"
  end

  def build_included_sets
    Set["rav", "gpt", "dis"]
  end
end

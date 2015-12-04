class FormatRavinicaBlock < Format
  def format_pretty_name
    "Ravnica Block"
  end

  def format_sets
    Set["rav", "gp", "di"]
  end
end

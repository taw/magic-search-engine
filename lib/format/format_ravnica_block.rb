class FormatRavinicaBlock < Format
  def format_name
    "ravnica block"
  end

  def format_sets
    Set["rav", "gp", "di"]
  end
end

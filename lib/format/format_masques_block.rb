class FormatMasquesBlock < Format
  def format_name
    "masques block"
  end

  def format_sets
    Set["mm", "ne", "pr"]
  end
end

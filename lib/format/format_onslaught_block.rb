class FormatOnslaughtBlock < Format
  def format_pretty_name
    "Onslaught Block"
  end

  def build_format_sets
    Set["on", "le", "sc"]
  end
end

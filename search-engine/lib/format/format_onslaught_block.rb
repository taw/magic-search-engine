class FormatOnslaughtBlock < Format
  def format_pretty_name
    "Onslaught Block"
  end

  def build_included_sets
    Set["ons", "lgn", "scg"]
  end
end

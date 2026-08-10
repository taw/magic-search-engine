class FormatOnslaughtBlock < Format
  def format_pretty_name
    "Onslaught Block"
  end

  def format_start_date
    "2002-10-07"
  end

  def build_included_sets
    Set["ons", "lgn", "scg"]
  end
end

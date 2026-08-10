class FormatAmonkhetBlock < Format
  def format_pretty_name
    "Amonkhet Block"
  end

  def format_start_date
    "2017-04-28"
  end

  def build_included_sets
    Set["akh", "hou"]
  end
end

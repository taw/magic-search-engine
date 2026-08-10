class FormatMirageBlock < Format
  def format_pretty_name
    "Mirage Block"
  end

  def format_start_date
    "1996-10-08"
  end

  def build_included_sets
    Set["mir", "vis", "wth"]
  end
end

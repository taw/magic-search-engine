class FormatKamigawaBlock < Format
  def format_pretty_name
    "Kamigawa Block"
  end

  def format_start_date
    "2004-10-01"
  end

  def build_included_sets
    Set["chk", "bok", "sok"]
  end
end

class FormatKamigawaBlock < Format
  def format_pretty_name
    "Kamigawa Block"
  end

  def build_included_sets
    Set["chk", "bok", "sok"]
  end
end

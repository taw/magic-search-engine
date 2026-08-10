class FormatUrzaBlock < Format
  def format_pretty_name
    "Urza Block"
  end

  def format_start_date
    "1998-10-12"
  end

  def build_included_sets
    Set["usg", "ulg", "uds"]
  end
end

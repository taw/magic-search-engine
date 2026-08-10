class FormatZendikarBlock < Format
  def format_pretty_name
    "Zendikar Block"
  end

  def format_start_date
    "2009-10-02"
  end

  def build_included_sets
    Set["zen", "wwk", "roe"]
  end
end

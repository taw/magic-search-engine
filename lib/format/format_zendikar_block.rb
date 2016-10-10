class FormatZendikarBlock < Format
  def format_pretty_name
    "Zendikar Block"
  end

  def build_format_sets
    Set["zen", "wwk", "roe"]
  end
end

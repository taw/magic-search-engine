class FormatOdysseyBlock < Format
  def format_pretty_name
    "Odyssey Block"
  end

  def format_start_date
    "2001-10-01"
  end

  def build_included_sets
    Set["ody", "tor", "jud"]
  end
end

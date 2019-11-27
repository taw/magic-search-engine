class FormatOdysseyBlock < Format
  def format_pretty_name
    "Odyssey Block"
  end

  def build_included_sets
    Set["ody", "tor", "jud"]
  end
end

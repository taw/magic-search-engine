class FormatOdysseyBlock < Format
  def format_pretty_name
    "Odyssey Block"
  end

  def build_format_sets
    Set["od", "tr", "ju"]
  end
end


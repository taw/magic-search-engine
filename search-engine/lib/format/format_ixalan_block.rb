class FormatIxalanBlock < Format
  def format_pretty_name
    "Ixalan Block"
  end

  def build_included_sets
    Set["xln"]
  end
end

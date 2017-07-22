class FormatAmonkhetBlock < Format
  def format_pretty_name
    "Amonkhet Block"
  end

  def build_included_sets
    Set["akh"]
  end
end

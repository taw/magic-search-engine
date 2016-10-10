class FormatUrzaBlock < Format
  def format_pretty_name
    "Urza Block"
  end

  def build_format_sets
    Set["us", "ul", "ud"]
  end
end


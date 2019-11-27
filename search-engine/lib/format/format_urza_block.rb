class FormatUrzaBlock < Format
  def format_pretty_name
    "Urza Block"
  end

  def build_included_sets
    Set["usg", "ulg", "uds"]
  end
end

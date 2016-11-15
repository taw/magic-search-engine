class FormatMasquesBlock < Format
  def format_pretty_name
    "Masques Block"
  end

  def build_included_sets
    Set["mm", "ne", "pr"]
  end
end

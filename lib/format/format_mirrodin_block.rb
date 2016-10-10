class FormatMirrodinBlock < Format
  def format_pretty_name
    "Mirrodin Block"
  end

  def build_format_sets
    Set["mi", "ds", "5dn"]
  end
end

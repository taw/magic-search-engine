class FormatMirageBlock < Format
  def format_pretty_name
    "Mirage Block"
  end

  def build_included_sets
    Set["mr", "vi", "wl"]
  end
end


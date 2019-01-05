class FormatMasquesBlock < Format
  def format_pretty_name
    "Masques Block"
  end

  def build_included_sets
    Set["mmq", "nem", "pcy"]
  end
end

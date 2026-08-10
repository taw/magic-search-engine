class FormatMasquesBlock < Format
  def format_pretty_name
    "Masques Block"
  end

  def format_start_date
    "1999-10-04"
  end

  def build_included_sets
    Set["mmq", "nem", "pcy"]
  end
end

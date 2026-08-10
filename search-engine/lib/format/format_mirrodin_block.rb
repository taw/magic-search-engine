class FormatMirrodinBlock < Format
  def format_pretty_name
    "Mirrodin Block"
  end

  def format_start_date
    "2003-10-02"
  end

  def build_included_sets
    Set["mrd", "dst", "5dn"]
  end
end

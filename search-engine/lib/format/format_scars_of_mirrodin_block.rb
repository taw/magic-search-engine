class FormatScarsOfMirrodinBlock < Format
  def format_pretty_name
    "Scars of Mirrodin Block"
  end

  def build_included_sets
    Set["som", "mbs", "nph"]
  end
end

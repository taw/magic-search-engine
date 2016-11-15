class FormatKaladeshBlock < Format
  def format_pretty_name
    "Kaladesh Block"
  end

  def build_included_sets
    Set["kld", "emn"]
  end
end

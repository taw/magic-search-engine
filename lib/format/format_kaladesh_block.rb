class FormatKaladeshBlock < Format
  def format_pretty_name
    "Kaladesh Block"
  end

  def build_format_sets
    Set["kld", "emn"]
  end
end

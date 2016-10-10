class FormatInvasionBlock < Format
  def format_pretty_name
    "Invasion Block"
  end

  def build_format_sets
    Set["in", "ps", "ap"]
  end
end

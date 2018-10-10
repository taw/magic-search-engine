class FormatInvasionBlock < Format
  def format_pretty_name
    "Invasion Block"
  end

  def build_included_sets
    Set["inv", "pls", "apc"]
  end
end

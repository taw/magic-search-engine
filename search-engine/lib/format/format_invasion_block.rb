class FormatInvasionBlock < Format
  def format_pretty_name
    "Invasion Block"
  end

  def format_start_date
    "2000-10-02"
  end

  def build_included_sets
    Set["inv", "pls", "apc"]
  end
end

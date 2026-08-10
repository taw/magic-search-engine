class FormatBattleForZendikarBlock < Format
  def format_pretty_name
    "Battle for Zendikar Block"
  end

  def format_start_date
    "2015-10-02"
  end

  def build_included_sets
    Set["bfz", "ogw"]
  end
end

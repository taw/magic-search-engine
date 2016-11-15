class FormatBattleForZendikarBlock < Format
  def format_pretty_name
    "Battle for Zendikar Block"
  end

  def build_included_sets
    Set["bfz", "ogw"]
  end
end

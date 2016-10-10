class FormatBattleForZendikarBlock < Format
  def format_pretty_name
    "Battle for Zendikar Block"
  end

  def build_format_sets
    Set["bfz", "ogw"]
  end
end

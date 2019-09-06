class FormatCustomBrawl < FormatCustomStandard
  def format_pretty_name
    "Custom Brawl"
  end

  def deck_legality(deck)
    brawl_legality(deck)
  end
end

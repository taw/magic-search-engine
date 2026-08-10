class FormatShadowsOverInnistradBlock < Format
  def format_pretty_name
    "Shadows Over Innistrad Block"
  end

  def format_start_date
    "2016-04-08"
  end

  def build_included_sets
    Set["soi", "emn"]
  end
end

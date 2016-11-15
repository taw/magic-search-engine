class FormatShadowsOverInnistradBlock < Format
  def format_pretty_name
    "Shadows Over Innistrad Block"
  end

  def build_included_sets
    Set["soi", "emn"]
  end
end

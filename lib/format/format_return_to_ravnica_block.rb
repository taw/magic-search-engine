class FormatReturnToRavnicaBlock < Format
  def format_pretty_name
    "Return to Ravnica Block"
  end

  def build_included_sets
    Set["rtr", "gtc", "dgm"]
  end
end

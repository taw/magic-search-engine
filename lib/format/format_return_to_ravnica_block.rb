class FormatReturnToRavnicaBlock < Format
  def format_pretty_name
    "Return to Ravnica Block"
  end

  def build_format_sets
    Set["rtr", "gtc", "dgm"]
  end
end

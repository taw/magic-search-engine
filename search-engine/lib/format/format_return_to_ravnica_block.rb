class FormatReturnToRavnicaBlock < Format
  def format_pretty_name
    "Return to Ravnica Block"
  end

  def format_start_date
    "2012-10-05"
  end

  def build_included_sets
    Set["rtr", "gtc", "dgm"]
  end
end

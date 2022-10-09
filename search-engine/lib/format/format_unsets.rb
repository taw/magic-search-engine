# Not sure if there's any point including this
# It's basically a joke to make Once More with Feeling match restricted:*

class FormatUnsets < Format
  def format_pretty_name
    "Unsets"
  end

  def build_included_sets
    Set["ugl", "unh", "ust"]
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      next unless @included_sets.include?(printing.set_code)
      return true
    end
    false
  end
end

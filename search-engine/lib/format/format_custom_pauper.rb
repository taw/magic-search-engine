class FormatCustomPauper < FormatCustomEternal
  def format_pretty_name
    "Custom Pauper"
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      next unless @included_sets.include?(printing.set_code)
      return true if printing.rarity == "common" or printing.rarity == "basic"
    end
    false
  end
end

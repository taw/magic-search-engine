class FormatPauper < FormatVintage
  def format_pretty_name
    "Pauper"
  end

  def in_format?(card)
    return false if card.funny
    # Format#in_format? excludes these too. Pauper overrides the whole method, so it
    # needs its own copy - mtgjson files Alchemy cards in the set they rebalance, and
    # plenty of those are commons.
    return false if card.alchemy
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      next if @excluded_sets.include?(printing.set_code)
      return true if printing.rarity == "common" or printing.rarity == "basic"
    end
    false
  end
end

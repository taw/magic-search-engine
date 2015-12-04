class FormatPauper < FormatVintage
  def format_pretty_name
    "Pauper"
  end

  def in_format?(card)
    raise unless card
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      next unless printing.rarity == "common"
      return true if @format_sets.include?(printing.set_code)
    end
    false
  end
end

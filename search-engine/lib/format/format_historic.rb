class FormatHistoric < FormatVintage
  def format_pretty_name
    "Historic"
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      # These are currently no excluded sets
      return true if printing.arena?
    end
    false
  end
end

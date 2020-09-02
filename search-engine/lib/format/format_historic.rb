class FormatHistoric < FormatVintage
  def format_pretty_name
    "Historic"
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      # These is currently one excluded set - XANA
      if printing.arena? and printing.set_code != "xana"
        return true
      end
    end
    false
  end
end

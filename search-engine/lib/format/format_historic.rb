class FormatHistoric < FormatVintage
  def format_pretty_name
    "Historic"
  end

  def legality(card)
    card = card.main_front if card.is_a?(PhysicalCard)
    if !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  def in_format?(card)
    return false if card.has_alchemy
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

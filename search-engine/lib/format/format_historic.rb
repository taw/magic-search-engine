class FormatHistoric < FormatVintage
  def format_pretty_name
    "Historic"
  end

  # Announced 2019-06-27, but the format only went live on Arena with the November 2019 update,
  # together with Historic Anthology 1 and the ranked Historic queue.
  # https://magic.wizards.com/en/articles/archive/magic-digital/mtg-arena-historic-rollout-2019-11-13
  def format_start_date
    "2019-11-21"
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

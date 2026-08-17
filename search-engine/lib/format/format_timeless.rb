class FormatTimeless < FormatHistoric
  def format_pretty_name
    "Timeless"
  end

  # Announced 2023-12-04, live on Arena together with the digital release of
  # Khans of Tarkir - the fetch lands are what the format was created for.
  # https://magic.wizards.com/en/news/mtg-arena/introducing-timeless-a-new-mtg-arena-format
  def format_start_date
    "2023-12-12"
  end

  # Same "everything on Arena" pool as Historic, with the rebalanced cards the
  # other way round. Historic plays the A- version of any card that has one and
  # not the original; Timeless plays "the original tabletop printings of all
  # non-digital cards", so the A- versions are what's out of the format here.
  #
  # Digital-only cards have no paper printing to be true to, and they're in
  # either way - mtgjson gives their rebalances no A- name of their own, so
  # there's nothing here that needs to tell them apart from a paper rebalance.
  def in_format?(card)
    return false if card.alchemy
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      # xana excluded for the same reason as in Historic
      if printing.arena? and printing.set_code != "xana"
        return true
      end
    end
    false
  end
end

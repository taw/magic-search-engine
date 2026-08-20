# What /download has always returned: the same file as the Text export with
# every printing taken off, which also merges the printings of a card into one
# line. The lowest common denominator - MTGO's own text export, Apprentice,
# Cockatrice, vendor mass entry and every "paste a decklist" box read it.
class DeckExporter::Names < DeckExporter::Text
  format "names", "Card names only", "txt"

  private

  def card_lines(cards)
    group_by_name(cards).map{|count, name| "#{count} #{name}" }
  end

  # Nothing here has a printing to warn about
  def warn_about_unknown_cards
  end
end

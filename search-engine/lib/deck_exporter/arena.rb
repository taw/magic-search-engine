# The line format MTG Arena introduced. What every destination shares is the
# *line* - "1 Arid Mesa (MH2) 244" - and not much else: of the nine tried, only
# Archidekt and Moxfield read this file whole. MythicHub keeps every card and
# flattens every section, MTGGoldfish ignores the Commander header, Deckstats
# reports every header as an unmatched card, TappedOut pastes into two boxes,
# Deckbox reads a blank line as "sideboard from here" and so puts the whole deck
# in the sideboard, and four of the nine drop any card carrying a finish marker.
#
# It is "Arena style" rather than Arena: paper set codes and paper collector
# numbers are what all of those want, and most paper cards are not on Arena
# under any spelling.
class DeckExporter::Arena < DeckExporter
  format "arena", "Arena style", "txt", "Archidekt, Moxfield"

  # Arena's own headers. Archidekt and Moxfield put the cards in the right zones;
  # MTGGoldfish reads Sideboard and ignores Commander; Deckstats and MPC Fill look
  # a header up as a card name; Deckbox skips them and splits on the blank line;
  # MythicHub ignores all three and flattens the deck.
  HEADERS = {"Commander" => "Commander", "Main Deck" => "Deck", "Sideboard" => "Sideboard"}

  private

  def generate
    commander, main, sideboard = commander_main_and_sideboard
    blocks = {"Commander" => commander, "Main Deck" => main, "Sideboard" => sideboard}
      .filter_map{|name, cards| [name, block(name, cards)] unless cards.empty? }
    warn_about_unknown_cards
    blocks.each_with_index.map{|(name, lines), index|
      (index.zero? ? "" : block_separator(name)) + lines.join("\n")
    }.join + "\n"
  end

  # The blank line between blocks is not decoration - Arena needs it to see the
  # next header. It is also what breaks Deckbox, where a blank line means
  # "sideboard from here", so the compatible subclass writes only one
  def block_separator(name)
    "\n\n"
  end

  def block(name, cards)
    [HEADERS.fetch(name)] + merge_cards(cards).map{|count, card| card_line(count, card) }
  end

  def card_line(count, card)
    return "#{count} #{card.name}" unless known?(card)
    [
      "#{count} #{card_name(card)}",
      " (#{card_set_code(card).upcase}) #{card_number(card)}",
      finish_marker(card),
    ].join
  end

  # Its own set code, unless a subclass writes the printing as something else
  def card_set_code(card)
    card.set_code
  end

  # Etched is a finish of its own everywhere this format is read, and every etched
  # card is foil as well, so `*E*` alone says it - `*F* *E*` would be asking for two
  # finishes at once. Same precedence the CSV's Finish column uses.
  def finish_marker(card)
    if card.etched
      " *E*"
    elsif card.foil
      " *F*"
    else
      ""
    end
  end

end

# The line format MTG Arena introduced. What every destination shares is the
# *line* - "1 Arid Mesa (MH2) 244" - and not much else: of the seven tried, only
# Archidekt and Moxfield read this file whole. MTGGoldfish ignores the Commander
# header, Deckstats reports every header as an unmatched card, TappedOut pastes
# into two boxes, and Arena, Deckstats and MTGGoldfish each drop a card that
# carries a finish marker. See _DECK_EXPORT_FRONTEND_v2.md §4.3.
#
# It is "Arena style" rather than Arena: paper set codes and paper collector
# numbers are what all of those want, and most paper cards are not on Arena
# under any spelling.
class DeckExporter::Arena < DeckExporter
  format "arena", "Arena style", "txt"

  # Arena's own headers. Archidekt and Moxfield put the cards in the right zones;
  # MTGGoldfish reads Sideboard and ignores Commander; Deckstats and MPC Fill look
  # a header up as a card name.
  HEADERS = {"Commander" => "Commander", "Main Deck" => "Deck", "Sideboard" => "Sideboard"}

  private

  def generate
    main, sideboard = main_and_sideboard
    blocks = [
      block("Commander", deck.section("Commander")),
      block("Main Deck", main),
      block("Sideboard", sideboard),
    ].compact
    warn_about_unknown_cards
    # The blank line between blocks is not decoration - Arena needs it to see
    # the next header
    blocks.map{|lines| lines.join("\n") }.join("\n\n") + "\n"
  end

  def block(name, cards)
    return nil if cards.empty?
    [HEADERS.fetch(name)] + cards.map{|count, card| card_line(count, card) }
  end

  def card_line(count, card)
    return "#{count} #{card.name}" unless known?(card)
    [
      "#{count} #{card_name(card)}",
      " (#{card.set_code.upcase}) #{card_number(card)}",
      finish_marker(card),
    ].join
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

  # The commander is a section of its own here, so only the exotic sections
  # have nowhere to go
  def main_and_sideboard
    main = deck.section("Main Deck")
    sideboard = deck.section("Sideboard").dup
    EXTRA_SECTIONS.each do |name|
      next if deck.section(name).empty?
      warn_about "#{name} cards go to the sideboard, as the format has no #{name.downcase}"
      sideboard += deck.section(name)
    end
    unless deck.section(DISPLAY_SECTION).empty?
      warn_about "#{DISPLAY_SECTION} left out, as it is an oversized copy of a card the deck already has"
    end
    [main, sideboard]
  end
end

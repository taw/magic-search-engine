# The line format MTG Arena introduced, which is the one thing nearly every
# site reads: Moxfield, Archidekt, Cockatrice, ManaBox, TappedOut, Deckstats,
# Scryfall, TopDecked, MythicHub, Draftmancer, and every proxy site.
#
# It is "Arena style" rather than Arena: paper set codes and paper collector
# numbers are what all of those want, and most paper cards are not on Arena
# under any spelling.
class DeckExporter::Arena < DeckExporter
  format "arena", "Arena style", "txt"

  # Arena's own headers. Every other reader either knows them or ignores them.
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
      card.foil ? " *F*" : "",
      card.etched ? " *E*" : "",
    ].join
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

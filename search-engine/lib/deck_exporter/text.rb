# What /download_with_printings has always returned: our own format, the only
# one which writes our per-face collector numbers, and the only one which can
# carry every section a deck has.
#
# XMage, MythicHub and mtg.wtf itself read it; nothing else does, which is what
# every other exporter here is for.
class DeckExporter::Text < DeckExporter
  format "text", "Text", "txt"

  private

  def generate
    output = metadata_comments
    card_lines(deck.section("Commander")).each do |line|
      output << "COMMANDER: #{line}"
    end
    output.concat(card_lines(deck.section("Main Deck")))
    sections.each do |name, cards|
      next if name == "Commander" or name == "Main Deck"
      output << ""
      output << name
      output.concat(card_lines(cards))
    end
    warn_about_unknown_cards
    output.join("\n") + "\n"
  end

  def card_lines(cards)
    cards.map{|count, card| "#{count} #{card_details(card)}" }
  end

  # Set code and collector number in one bracket after the name, foil and
  # etched as separate tags after that
  def card_details(card)
    return card.name unless known?(card)
    [
      card.name,
      " [#{card.set_code.upcase}:#{card_number(card)}]",
      card.foil ? " [foil]" : "",
      card.etched ? " [etched]" : "",
    ].join
  end

  # Our own format is the one place where the per-face number is right: it is
  # what our own parser reads back, and what the deck pages link to
  def card_number(card)
    card.number
  end

  def metadata_comments
    output = []
    output << "// NAME: #{deck.full_name}" if deck.full_name
    output << "// URL: #{deck.canonical_url}" if deck.canonical_url
    output.concat(display_comment)
    output << "// DATE: #{deck.release_date}" if deck.release_date
    output
  end

  # Display text can have multiple lines, and every one of them needs to be
  # commented out, or a parser will read the rest as cards
  def display_comment
    deck.display.to_s.lines.map(&:chomp).map.with_index do |line, i|
      i == 0 ? "// DISPLAY: #{line}" : "// #{line}"
    end
  end
end

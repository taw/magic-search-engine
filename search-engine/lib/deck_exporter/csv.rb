# The collection shape: one row per printing, with a column for everything we
# know about it. Moxfield, ManaBox, Archidekt, Deckbox, Dragon Shield and
# TopDecked all import a close variant of this header, and it is the only
# format here whose own column can carry the section a card came from, so
# nothing has to be merged or dropped.
class DeckExporter::Csv < DeckExporter
  format "csv", "CSV", "csv"

  HEADER = ["Section", "Count", "Name", "Set code", "Set name", "Collector number", "Finish"]

  # RFC 4180 says CRLF, Dragon Shield insists on it, and every other importer
  # takes either
  EOL = "\r\n"

  private

  def generate
    rows = [HEADER]
    sections.each do |name, cards|
      cards.each do |count, card|
        rows << row(name, count, card)
      end
    end
    warn_about_unknown_cards
    rows.map{|row| row.map{|field| quote(field) }.join(",") + EOL }.join
  end

  def row(section, count, card)
    return [section, count, card.name, nil, nil, nil, nil] unless known?(card)
    [
      section,
      count,
      card_name(card),
      card.set_code.upcase,
      card.set.name,
      card_number(card),
      finish(card),
    ]
  end

  # The three values every collection site agrees on. A card can be both foil
  # and etched, and etched is the more specific of the two.
  def finish(card)
    if card.etched
      "Etched"
    elsif card.foil
      "Foil"
    else
      "Normal"
    end
  end

  def quote(field)
    field = field.to_s
    if field =~ /[",\r\n]/
      '"' + field.gsub('"', '""') + '"'
    else
      field
    end
  end
end

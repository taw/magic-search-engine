# MythicHub's own format, read from what its site exports:
#
#   == COMMANDER ==
#   1 Kitsa, Otterball Elite [BLB] #54
#   == MAINBOARD ==
#   1 Delver of Secrets [ISD] #51
#   1 Talisman of Progress [SLD] #1052 etched
#
#   == SIDEBOARD ==
#   1 Naturalize [M10] #195
#
# It is the only format here besides our own which carries all four of a
# commander zone, a sideboard, the exact printing and the finish. Cockatrice
# and XMage cannot say a finish, MTGO carries no set code at all, and every
# arena style reader is missing at least one of the four.
#
# The blank line goes before the sideboard and nowhere else, which is the rule
# our own text format has always used, arrived at here independently.
#
# It writes both faces of a double faced card where we write the front list,
# but it read our front list names when we sent them, so those stay as every
# other format writes them. Checked by round trip: a file this writes imports
# there and comes back the same deck, zones and finishes included.
class DeckExporter::MythicHub < DeckExporter
  format "mythichub", "MythicHub", "txt"

  private

  def generate
    commander, main, sideboard = commander_main_and_sideboard
    warn_about_unknown_cards
    [
      block("COMMANDER", commander),
      block("MAINBOARD", main),
      block("SIDEBOARD", sideboard),
    ].compact.join("\n") + "\n"
  end

  def block(name, cards)
    return nil if cards.empty?
    # The sideboard is the one section with a blank line in front of it: a
    # reader which splits on blank lines and one which reads the header both
    # put the card in the same place
    separator = ("\n" if name == "SIDEBOARD")
    ["#{separator}== #{name} ==", *cards.map{|count, card| card_line(count, card) }].join("\n")
  end

  def card_line(count, card)
    return "#{count} #{card_name(card)}" unless known?(card)
    [
      "#{count} #{card_name(card)}",
      " [#{card.set_code.upcase}] ##{card_number(card)}",
      finish(card),
    ].join
  end

  # Spelled out rather than marked, and etched wins over foil - the same
  # precedence the CSV's Finish column uses
  def finish(card)
    if card.etched
      " etched"
    elsif card.foil
      " foil"
    else
      ""
    end
  end
end

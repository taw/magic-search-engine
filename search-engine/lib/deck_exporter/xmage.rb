# XMage's own .dck format. The same [SET:NUM] bracket our text export uses,
# except XMage puts it before the name - and its importer matches one regexp
# against the whole line, so a line with the bracket in our place is dropped
# without a word.
#
# XMage looks a card up by set and number first and by name second, so both
# have to be XMage's: physical-card numbers (ISD:51, never ISD:51a) and the
# front-list names its card database uses.
class DeckExporter::Xmage < DeckExporter
  format "xmage", "XMage", "dck"

  # XMage joins split and aftermath cards under a two-part name and nothing
  # else - `data/xmage_cards.txt` lists "Fire" and "Ice" separately for apc 128
  # but only "Besotted Knight" for woe 4. This matters more here than anywhere:
  # when the name does not match the card its own set and number found, XMage
  # throws that match away and falls back to a name lookup which then fails.
  JOINED_LAYOUTS = ["split", "aftermath"]

  private

  # XMage has no foil, so the two finishes of a printing are one line
  def merge_key(card)
    printing_key(card)
  end

  def card_name(card)
    joined_name(card, JOINED_LAYOUTS)
  end

  def generate
    main, sideboard = main_and_sideboard
    output = metadata_lines
    output.concat(merge_cards(main).map{|count, card| card_line(count, card) })
    output.concat(merge_cards(sideboard).map{|count, card| "SB: #{card_line(count, card)}" })
    warn_about_unknown_cards
    warn_about_dropped_finishes
    output.join("\n") + "\n"
  end

  def card_line(count, card)
    return "#{count} #{card.name}" unless known?(card)
    "#{count} [#{card.set_code.upcase}:#{card_number(card)}] #{card_name(card)}"
  end

  # NAME: is XMage's own metadata line; anything else has to be a comment, and
  # a comment is a line starting with #
  def metadata_lines
    output = []
    output << "NAME: #{deck.full_name}" if deck.full_name
    output << "# URL: #{deck.canonical_url}" if deck.canonical_url
    output << "# DATE: #{deck.release_date}" if deck.release_date
    output
  end

  # XMage drops a line it cannot parse, and a card with no printing has no
  # bracket to parse
  def warn_about_unknown_cards
    unknown = deck.all_cards.reject{|_, card| known?(card) }
    return if unknown.empty?
    warn_about "Not in our database, so XMage will skip: #{card_list(unknown.map{|_, card| card.name })}"
  end
end

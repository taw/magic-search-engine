# Cockatrice's .cod file. It writes and reads setShortName, collectorNumber
# and uuid on every card, so unlike the plain text it also writes, this one
# keeps the printing.
#
# The uuid is the load-bearing one. Opening a .cod resolves each card by name
# and uuid only (`DecklistCardNode::toCardRef`), and a card with no uuid gets
# `getPreferredPrinting` - whichever printing Cockatrice itself favours - so
# without it the set and number we wrote are shown in the columns while the
# actual card in the deck is some other printing. Only its clipboard, website
# and Archidekt importers run `ResolveProviderId`, which is the code path that
# looks a printing up by set and number.
#
# Its card database is built from mtgjson, so the set code is the mtgjson code
# uppercased and the number is the physical-card number. Names are mtgjson's
# too: split, aftermath, adventure and prepare cards are stored under the full
# name, everything else with a back face under the front face's name alone.
class DeckExporter::Cockatrice < DeckExporter
  format "cockatrice", "Cockatrice", "cod"

  # The layouts Cockatrice merges into a single card, from its own importer
  JOINED_LAYOUTS = ["split", "aftermath", "adventure", "prepare"]

  private

  def generate
    main, sideboard = main_and_sideboard
    @scryfall_ids = ScryfallIds.lookup(deck.physical_cards.grep(PhysicalCard))
    warn_about_unknown_cards
    warn_about_dropped_finishes
    [
      %Q[<?xml version="1.0" encoding="UTF-8"?>],
      %Q[<cockatrice_deck version="1">],
      %Q[    <deckname>#{escape(deck.full_name || deck.name)}</deckname>],
      %Q[    <comments>#{escape(comments)}</comments>],
      zone("main", main),
      zone("side", sideboard),
      %Q[</cockatrice_deck>],
      "",
    ].compact.join("\n")
  end

  def zone(name, cards)
    return nil if cards.empty?
    [
      %Q[    <zone name="#{name}">],
      *merge_cards(cards).map{|count, card| card_element(count, card) },
      %Q[    </zone>],
    ].join("\n")
  end

  def card_element(count, card)
    attributes = {"number" => count, "name" => card_name(card)}
    if known?(card)
      attributes["setShortName"] = card.set_code.upcase
      attributes["collectorNumber"] = card_number(card)
      attributes["uuid"] = @scryfall_ids[card] if @scryfall_ids[card]
    end
    %Q[        <card #{attributes.map{|k,v| %Q[#{k}="#{escape(v)}"] }.join(" ")}/>]
  end

  # Cockatrice has no foil, so the two finishes of a printing are one card
  def merge_key(card)
    printing_key(card)
  end

  # Cockatrice keeps a flip card's faces as two cards named after one face
  # each, so our front list is one name too many for those
  def card_name(card)
    joined_name(card, JOINED_LAYOUTS)
  end

  def comments
    [deck.canonical_url, deck.release_date, deck.display].compact.join("\n")
  end

  def escape(text)
    text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
  end
end

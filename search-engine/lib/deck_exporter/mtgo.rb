# MTGO's .dek file. It is XML, it carries no set codes and no collector
# numbers, and cards are identified by CatID - MTGO's own catalog id, which is
# the only thing MTGO itself matches on. Cards it has no id for are simply not
# on MTGO, and are left out with a warning.
class DeckExporter::Mtgo < DeckExporter
  format "mtgo", "MTGO", "dek"

  JOINED_LAYOUTS = ["split", "aftermath"]

  private

  def generate
    main, sideboard = main_and_sideboard
    @ids = MtgoIds.lookup(deck.physical_cards.grep(PhysicalCard))
    lines = [
      %Q[<?xml version="1.0" encoding="utf-8"?>],
      %Q[<Deck xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">],
      %Q[  <NetDeckID>0</NetDeckID>],
      %Q[  <PreconstructedDeckID>0</PreconstructedDeckID>],
      *card_elements(main, false),
      *card_elements(sideboard, true),
      %Q[</Deck>],
      "",
    ]
    warn_about_missing_ids
    warn_about_dropped_finishes
    lines.join("\n")
  end

  def card_elements(cards, sideboard)
    cards.filter_map do |count, card|
      id = @ids[card] if known?(card)
      unless id
        missing << card
        next
      end
      %Q[  <Cards CatID="#{id}" Quantity="#{count}" Sideboard="#{sideboard}" Name="#{escape(card_name(card))}" />]
    end
  end

  # MTGO writes a split card's halves with a bare slash between them and knows
  # everything else by its front face alone. The name is decoration as far as
  # MTGO is concerned, since it matches on CatID, but XMage reads .dek files
  # too and matches on nothing else.
  def card_name(card)
    joined_name(card, JOINED_LAYOUTS, "/")
  end

  def missing
    @missing ||= []
  end

  def warn_about_missing_ids
    return if missing.empty?
    if @ids.empty?
      warn_about "No card in this deck is on MTGO, so this file has nothing in it"
    else
      warn_about "Not on MTGO, so left out: #{card_list(missing.map(&:name))}"
    end
  end

  def escape(text)
    text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
  end
end

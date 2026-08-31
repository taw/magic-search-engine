# MTGO's .dek file. It is XML, it carries no set codes and no collector
# numbers, and cards are identified by CatID - MTGO's own catalog id, which is
# the only thing MTGO itself matches on. Cards it has no id for are simply not
# on MTGO, and are left out with a warning.
#
# A finish is a CatID too: MTGO sells the premium copy as a catalog object of
# its own, so a foil card is a different id rather than a flag on the normal
# one. It has exactly one premium finish, so an etched card asks for the same
# object a foil one does, and a printing MTGO never sold a premium copy of has
# nothing to ask for at all.
class DeckExporter::Mtgo < DeckExporter
  format "mtgo", "MTGO", "dek"

  JOINED_LAYOUTS = ["split", "aftermath"]

  private

  def generate
    main, sideboard = main_and_sideboard
    @ids = MtgoIds.lookup(deck.physical_cards.grep(PhysicalCard))
    @catalog_ids = catalog_ids
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
    warn_about_finishes
    lines.join("\n")
  end

  # {card => the id this very card is} - the premium one where the card asks
  # for a finish and MTGO has one, and otherwise the normal one. Done in one
  # pass up front, because both the lines and the merging want the answer, and
  # the warnings must be about cards rather than about lines.
  def catalog_ids
    @ids.to_h do |card, (id, premium_id)|
      next [card, id] unless card.foil or card.etched
      if premium_id
        etched_as_foil << card if card.etched
        [card, premium_id]
      else
        no_premium << card
        [card, id]
      end
    end
  end

  def card_elements(cards, sideboard)
    merge_cards(cards).filter_map do |count, card|
      id = @catalog_ids[card] if known?(card)
      unless id
        missing << card
        next
      end
      %Q[  <Cards CatID="#{id}" Quantity="#{count}" Sideboard="#{sideboard}" Name="#{escape(card_name(card))}" />]
    end
  end

  # A catalog id is one entry in MTGO's collection, so anything which lands on
  # the same id is one line - any two printings which fell back to the same id,
  # and the two finishes of a printing MTGO has no premium copy of. Cards with
  # no id are dropped anyway, and only need to be told apart for the warning.
  def merge_key(card)
    @catalog_ids[card] || card.name
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

  def no_premium
    @no_premium ||= []
  end

  def etched_as_foil
    @etched_as_foil ||= []
  end

  def warn_about_missing_ids
    return if missing.empty?
    if @ids.empty?
      warn_about "No card in this deck is on MTGO, so this file has nothing in it"
    else
      warn_about "Not on MTGO, so left out: #{card_list(missing.map(&:name))}"
    end
  end

  def warn_about_finishes
    unless no_premium.empty?
      warn_about "Exported as normal cards, as MTGO has no premium copy of them: #{card_list(no_premium.map(&:name))}"
    end
    unless etched_as_foil.empty?
      warn_about "Exported as foil, as MTGO has no etched finish: #{card_list(etched_as_foil.map(&:name))}"
    end
  end

  def escape(text)
    text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
  end
end

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

  def generate
    main, sideboard = main_and_sideboard
    resolve_printings
    output = metadata_lines
    output.concat(merge_cards(main).map{|count, card| card_line(count, card) })
    output.concat(merge_cards(sideboard).map{|count, card| "SB: #{card_line(count, card)}" })
    warn_about_substituted_printings
    warn_about_missing_cards
    warn_about_unknown_cards
    warn_about_dropped_finishes
    output.join("\n") + "\n"
  end

  def card_line(count, card)
    printing = printing_for(card)
    # Only a card we know nothing about gets here without a printing, and a
    # line with no bracket does not match XMage's importer at all - it is
    # skipped without a word, which is the one thing we cannot help
    return "#{count} #{card_name(card)}" unless printing
    "#{count} [#{printing.set_code.upcase}:#{card_number(printing)}] #{card_name(card)}"
  end

  # XMage's card database is not ours: it has no The List, no Secret Lair, and
  # no Doctor Who planes. Rather than write a printing it will reject, write
  # the printing it would have picked itself: from
  # CardRepository#findPreferredOrLatestCard, the newest printing from a set
  # which was ever standard legal, and otherwise just the newest.
  #
  # When it has no printing of the card at all, we write ours anyway. XMage
  # answers that with "can't find card" in its import report, which is the
  # point: a card it cannot have should be something the person importing sees,
  # not a line quietly missing from their deck.
  def resolve_printings
    @printings = {}
    @substituted = []
    @missing = []
    deck.physical_cards.grep(PhysicalCard).each do |card|
      if card.main_front.xmage
        @printings[card] = card
        next
      end
      printing = preferred_xmage_printing(card)
      @printings[card] = printing || card
      (printing ? @substituted : @missing) << card
    end
  end

  def preferred_xmage_printing(card)
    printings = card.main_front.card.printings.select(&:xmage)
    return nil if printings.empty?
    PhysicalCard.for(printings.max_by{|printing|
      [printing.set.types.include?("standard") ? 1 : 0, printing.set.release_date]
    })
  end

  def printing_for(card)
    @printings[card] if known?(card)
  end

  # Two cards XMage writes the same way are one line, and after a substitution
  # that can be two printings which are one printing to XMage
  def merge_key(card)
    printing = printing_for(card)
    printing ? printing_key(printing) : card_name(card)
  end

  def card_name(card)
    joined_name(card, JOINED_LAYOUTS)
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

  def warn_about_substituted_printings
    return if @substituted.empty?
    warn_about "XMage does not have these printings, so another printing of the same card is used: #{card_list(@substituted.map(&:name))}"
  end

  def warn_about_missing_cards
    return if @missing.empty?
    warn_about "Not in XMage at all, so it will report them as missing: #{card_list(@missing.map(&:name))}"
  end

  # XMage drops a line it cannot parse, and a card with no printing has no
  # bracket to parse
  def warn_about_unknown_cards
    unknown = deck.all_cards.reject{|_, card| known?(card) }
    return if unknown.empty?
    warn_about "Not in our database, so XMage will skip: #{card_list(unknown.map{|_, card| card.name })}"
  end
end

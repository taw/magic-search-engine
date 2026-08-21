# The Arena style lines with the two things most readers choke on taken out.
#
# The finish markers: of the destinations tried, Arena, Deckstats, MTGGoldfish
# and Deckbox all drop the whole card when a line carries one, and TappedOut
# parses it and throws it away. Only Archidekt, Moxfield and MythicHub keep it.
# A marker which costs the card in four places to say "foil" in three is not
# what you send somewhere you have not tried.
#
# The List printings: MTGGoldfish, TappedOut and Deckbox have no PLST at all.
# But The List's collector number *is* the original printing's set and number -
# "WWK-121" is Worldwake 121 - so the card it is a copy of can be written
# instead, which is a different printing rather than no card. Every one of our
# 5,135 The List printings resolves that way.
class DeckExporter::ArenaCompatible < DeckExporter::Arena
  format "arena_compatible", "Arena style (maximum compatibility)", "txt", "MTGGoldfish, TappedOut, Deckbox, Deckstats"

  # The only set whose collector numbers name another printing
  THE_LIST = "plst"

  private

  def generate
    text = super
    warn_about_dropped_finishes
    warn_about_substitutions
    text
  end

  # One blank line, before the sideboard and nowhere else. Deckbox reads a
  # blank line as "sideboard from here" and skips the headers, so with a blank
  # after the commander block its whole deck lands in the sideboard; with this
  # one, a reader which splits on blank lines and a reader which reads the
  # header both put the card in the same place. Our own text format and
  # MythicHub's both do it this way.
  def block_separator(name)
    name == "Sideboard" ? "\n\n" : "\n"
  end

  # Nothing is written which could say which finish a card is
  def finish_marker(card)
    ""
  end

  # Which makes a printing's foil and nonfoil one line, exactly as they are for
  # Cockatrice and XMage - and a The List card and the printing it copies too,
  # if a deck has both. The key is what gets written, not what we hold.
  def merge_key(card)
    return card.name unless known?(card)
    [card_set_code(card), card_number(card)]
  end

  def card_set_code(card)
    substituted(card).set_code
  end

  def card_number(card)
    super(substituted(card))
  end

  # The printing this format writes for a card: its own, unless it is a The
  # List card, in which case the printing The List copied.
  def substituted(card)
    return card unless known?(card) and card.set_code == THE_LIST
    @substituted ||= {}
    @substituted[card] ||= the_list_original(card) || card
  end

  def the_list_original(card)
    set_code, number = card.physical_card_number.split("-", 2)
    return nil unless number
    candidates = card.main_front.card.printings.select{|printing| printing.set_code == set_code.downcase }
    return nil if candidates.empty?
    # Five of The List's numbers name a printing its own set numbers
    # differently - Judgment's daggers, Brothers Yamazaki's 160a and 160b - and
    # any printing from the right set beats a set code nothing has
    original = candidates.find{|printing| PhysicalCard.new(printing).physical_card_number == number } || candidates.first
    substituted_cards << card.name
    PhysicalCard.new(original, card.finish)
  end

  def warn_about_substitutions
    return if substituted_cards.empty?
    warn_about "The List printings exported as the printing they copy, as most readers have no PLST: #{card_list(substituted_cards)}"
  end

  def substituted_cards
    @substituted_cards ||= []
  end
end

# Scryfall ids, which Cockatrice calls a provider id and which are the only
# thing it resolves a .cod file's cards by - it reads setShortName and
# collectorNumber into its columns, but picks the printing from the uuid alone,
# and falls back to whichever printing it prefers when there is none.
#
# 112k of them, so they are read the same way as the MTGO ids: one pass over
# the file per export, keeping only what that deck asked for, and nothing kept
# in memory afterwards. Unlike MTGO ids there is no fallback to another
# printing - the id is the printing.
class ScryfallIds
  PATH = Pathname(__dir__) + "../../index/scryfall_ids.txt"

  # cards -> {card => scryfall id}
  def self.lookup(cards, path=PATH)
    return {} if cards.empty?

    # A list per key, because the finishes of one printing are separate cards
    # here and share the one row
    wanted = {}
    cards.each do |card|
      (wanted[[card.set_code, card.number]] ||= []) << card
    end

    result = {}
    path.each_line do |line|
      set_code, number, id, _name = line.chomp.split("\t")
      wanted[[set_code, number]]&.each do |card|
        result[card] = id
      end
    end
    result
  end
end

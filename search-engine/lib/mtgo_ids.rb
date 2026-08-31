# MTGO catalog ids, which MTGO's own .dek files identify cards by, and which
# nothing else here needs.
#
# There are 64k of them, so they live in a file of their own rather than in the
# index the server keeps in memory: an export reads the file once, keeps only
# the ids that one deck asked for, and throws the rest away.
#
# MTGO does not care which printing you own, so a card whose own printing has
# no id falls back to another printing of the same card - the lowest id, which
# is that card's first appearance on MTGO. Over the decks we ship that takes
# full coverage from 1301 decks to 2733 of 3004.
class MtgoIds
  PATH = Pathname(__dir__) + "../../index/mtgo_ids.txt"

  # cards -> {card => catalog id}, leaving out the cards MTGO does not have
  def self.lookup(cards, path=PATH)
    return {} if cards.empty?

    # Both are lists, because the finishes of one printing are separate cards
    # here, and every card is asked about under both of its keys
    wanted_printings = {}
    wanted_names = {}
    cards.each do |card|
      (wanted_printings[[card.set_code, card.number]] ||= []) << card
      (wanted_names[card.main_front.name] ||= []) << card
    end

    by_card = {}
    lowest_by_name = {}
    path.each_line do |line|
      # The premium (foil) id is in the file but nothing asks for it yet
      set_code, number, id, _foil_id, name = line.chomp.split("\t")
      wanted_printings[[set_code, number]]&.each do |card|
        by_card[card] = id
      end
      if wanted_names.key?(name) and (lowest_by_name[name].nil? or id.to_i < lowest_by_name[name].to_i)
        lowest_by_name[name] = id
      end
    end

    wanted_names.each do |name, name_cards|
      id = lowest_by_name[name] or next
      name_cards.each do |card|
        by_card[card] ||= id
      end
    end
    by_card
  end
end

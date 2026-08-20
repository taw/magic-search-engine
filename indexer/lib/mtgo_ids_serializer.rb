# MTGO catalog ids, in the same shape as the Scryfall ids: one row per
# printing, keyed by our set code and our per-face number.
#
# Only the .dek export uses these, and only a few dozen at a time, so they stay
# out of the index the search engine loads - see MtgoIds.
class MtgoIdsSerializer
  def initialize(cards)
    @cards = cards
  end

  def to_s
    @cards.flat_map do |name, printings|
      printings.filter_map do |data|
        id = data.dig("identifiers", "mtgoId")
        [data["set_code"], data["number"], id, name] if id
      end
    end
      .sort_by{|sc,n,id,name| [sc, n.to_i, n, name, id] }
      .map{|row| row.join("\t") + "\n" }
      .join
  end
end

class ScryfallIdsSerializer
  def initialize(cards)
    @cards = cards
  end

  def to_s
    @cards.flat_map do |name, printings|
      printings.map do |data|
        [data["set_code"], data["number"], data.dig("identifiers", "scryfallId"), name]
      end
    end
      .sort_by{|sc,n,u,name| [sc, n.to_i, n, name, u || ""] }
      .map{|row| row.join("\t") + "\n" }
      .join
  end
end

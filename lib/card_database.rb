require "pathname"
require "json"
require_relative "card"
require_relative "card_set"
require_relative "card_printing"
require_relative "query"

class CardDatabase
  def initialize(path)
    @path = Pathname(path)
    @data = JSON.parse(@path.open.read)
    @sets = {}
    @cards = {}
    @ci = {}
    parse_data!
  end

  def search(query_string)
    query = Query.new(query_string)
    results = []
    each_card do |card|
      if query.match?(card)
        results << card.name
      end
    end
    results.uniq.sort
  end

  def each_card
    @cards.each do |card_name, card|
      card.printings.each do |printing|
        yield printing
      end
    end
  end

  def cards
    enum_for(:each_card).to_a
  end

  private

  def parse_data!
    @data["sets"].each do |set_code, set_data|
      @sets[set_code] = CardSet.new(set_data)
    end
    @data["cards"].each do |card_name, card_data|
      card = @cards[card_name] = Card.new(card_data.reject{|k,_| k == "printings"})
      @ci[card_name] ||= card.partial_color_identity
      card_data["printings"].each do |set_code, printing_data|
        card.printings << CardPrinting.new(
          card,
          @sets[set_code],
          printing_data
        )
      end
    end
    @cards.each do |card_name, card|
      if card.has_multiple_parts?
        card.color_identity = card.names.map{|n| @ci[n]}.inject(&:|)
       end
     end
  end
end

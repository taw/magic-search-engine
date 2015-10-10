require "pathname"
require "json"
require_relative "card"
require_relative "query"

class CardDatabase
  def initialize(path)
    @path = Pathname(path)
    @data = JSON.parse(@path.open.read)
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
    @data.each do |set_code, set|
      set["cards"].each do |card_data|
        yield Card.new(card_data.merge("set_code" => set_code, "set_name" => set["name"]))
      end
    end
  end

  def cards
    enum_for(:each_card).to_a
  end
end

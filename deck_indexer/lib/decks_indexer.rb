require "date"
require "json"
require "pathname"
require "pry"

class DecksIndexer
  attr_reader :sets, :cards

  def initialize(card_index_json, decks_json, save_path)
    main_index = JSON.parse(Pathname(card_index_json).read)
    @sets = main_index["sets"]
    @cards = main_index["cards"]
    @decks = JSON.parse(Pathname(decks_json).read)
    @save_path = Pathname(save_path)
  end

  def call
    index = @decks.map do |deck|
      if @sets[deck["set_code"]]
        DeckIndexer.new(self, deck).call
      else
        warn "Unknown set #{deck["set_code"]}"
        nil
      end
    end.compact
    @save_path.write(index.to_json)
  end

  def inspect
    self.class.to_s
  end
end

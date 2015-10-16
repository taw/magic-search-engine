require "pathname"
require "json"
require "set"
require_relative "card"
require_relative "card_set"
require_relative "card_printing"
require_relative "query"

class CardDatabase
  attr_reader :sets, :cards, :blocks
  def initialize
    @sets = {}
    @blocks = Set[]
    @cards = {}
    yield(self)
  end

  def search(query)
    query = Query.new(query) unless query.is_a?(Query)
    query.search(self)
  end

  def search_card_names(query_string)
    search(query_string).map(&:name).uniq
  end

  def each_printing
    @cards.each do |card_name, card|
      card.printings.each do |printing|
        yield printing
      end
    end
  end

  def printings
    @printings ||= Set.new(enum_for(:each_printing))
  end

  def subset(sets)
    # puts "Loading subset: #{sets}"
    self.class.send(:new) do |db|
      db.send(:load_from_subset!, self, sets)
    end
  end

  class <<self
    private :new

    def load(path)
      # puts "Initialize #{path}"
      new do |db|
        db.send(:load_from_json!, Pathname(path))
      end
    end
  end

  private

  def load_from_subset!(db, sets)
    @blocks = db.blocks
    db.sets.each do |set_code, set|
      next unless sets.include?(set_code)
      @sets[set_code] = set
    end
    db.cards.each do |card_name, card|
      printings = card.printings.select do |printing|
        sets.include?(printing.set_code)
      end
      next if printings.empty?
      @cards[card_name] = card.dup
      @cards[card_name].printings = printings
    end
    # color_identity already set in parent database
  end

  def load_from_json!(path)
    color_identity_cache = {}
    multipart_cards = {}
    data = JSON.parse(path.open.read)
    data["sets"].each do |set_code, set_data|
      # It's OK to link to main one, it's only needed for set/block codes list
      # and that might as well be hardcoded
      @sets[set_code] = CardSet.new(set_data, self)
      if set_data["block_code"]
        @blocks << set_data["block_code"]
        @blocks << normalize_name(set_data["block_name"])
      end
    end
    data["cards"].each do |card_name, card_data|
      # Do not include ever
      next if card_data["layout"] == "token"
      if ["vanguard", "plane", "scheme", "phenomenon"].include?(card_data["layout"]) or
         card_data["types"].include?("Conspiracy")
        # Do not include in default search results
        card_data["extra"] = true
      end
      card = @cards[card_name] = Card.new(card_data.reject{|k,_| k == "printings"})
      color_identity_cache[card_name] = card.partial_color_identity
      if card_data["names"]
        multipart_cards[card_name] = card_data["names"] - [card_name]
      end
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
        card.color_identity = card.names.map{|n| color_identity_cache[n].chars }.inject(&:|).sort.join
      end
    end
    multipart_cards.each do |card_name, other_names|
      card = @cards[card_name]
      other_cards = other_names.map{|name| @cards[name] }
      card.printings.each do |printing|
        printing.others = other_cards.map do |other_card|
          from_same_set = other_card.printings.select{|other_printing| other_printing.set_code == printing.set_code}
          raise "Can't link other side" unless from_same_set.size == 1
          from_same_set[0]
        end
      end
    end
  end

  private

  # These method seem to occur in every single class out there
  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end
end

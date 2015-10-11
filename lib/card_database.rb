require "pathname"
require "json"
require_relative "card"
require_relative "card_set"
require_relative "card_printing"
require_relative "query"

# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
end

MagicBlocks = [
  # Sort of not really:
  ["ia", "Ice Age", "ia", "ai", "cs"],
  # ["shm", "Shadowmoor", "shm", "eve"], # Also included in Lorwyn
  ["mr", "Mirage", "mr", "vi", "wl"],
  ["tp", "Tempest", "tp", "sh", "ex"],
  ["us", "Urza's Saga", "us", "ul", "ud"],
  ["mm", "Mercadian Masques", "mm", "ne", "pr"],
  ["in", "Invasion", "in", "ps", "ap"],
  ["od", "Odyssey", "od", "tr", "ju"],
  ["on", "Onslaught", "on", "le", "sc"],
  ["mi", "Mirrodin", "mi", "ds", "5dn"],
  ["chk", "Champions of Kamigawa", "chk", "bok", "sok"],
  ["rav", "Ravnica: City of Guilds", "rav", "gp", "di"],
  ["ts", "Time Spiral", "ts", "tsts", "pc", "fut"],
  ["lw", "Lorwyn", "lw", "mt", "shm", "eve"],
  ["ala", "Shards of Alara", "ala", "cfx", "arb"],
  ["zen", "Zendikar", "zen", "wwk", "roe"],
  ["som", "Scars of Mirrodin", "som", "mbs", "nph"],
  ["isd", "Innistrad", "isd", "dka", "avr"],
  ["rtr", "Return to Ravnica", "rtr", "gtc", "dgm"],
  ["ths", "Theros", "ths", "bng", "jou"],
  ["ktk", "Khans of Tarkir", "ktk", "frf", "dtk"],
  ["bfz", "Battle for Zendikar", "bfz"],
]

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
    @data.each do |set_code, set_data|
      set_code = set_data["magicCardsInfoCode"] || set_data["code"]
      block = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
      set = @sets[set_code] = CardSet.new(
        "set_code" => set_code,
        "set_name" => set_data["name"],
        "block_code" => block[0],
        "block_name" => block[1],
        "border" => set_data["border"],
        "releaseDate" => set_data["releaseDate"],
      )
      set_data["cards"].each do |card_data|
        name = card_data["name"]
        card = @cards[name] ||= begin
          Card.new(card_data.slice(
            "name",
            "names",
            "power",
            "toughness",
            "loyalty",
            "manaCost",
            "text",
            "types",
            "subtypes",
            "supertypes",
            "legalities",
            "colors",
            "cmc",
            "layout",
          ))
        end
        card.printings << CardPrinting.new(
          card,
          set,
          card_data.slice(
            "flavor",
            "artist",
            "border",
            "releaseDate",
            "rarity",
            "timeshifted",
            "watermark",
          ),
        )
        @ci[card.name] ||= card.partial_color_identity
      end
    end
    @cards.each do |card_name, card|
      if card.has_multiple_parts?
        card.color_identity = card.names.map{|n| @ci[n]}.inject(&:|)
      end
    end
  end
end

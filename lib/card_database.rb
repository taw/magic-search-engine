require "pathname"
require "json"
require_relative "card"
require_relative "query"

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
      set_code = set["magicCardsInfoCode"] || set["code"]
      block = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
      set["cards"].each do |card_data|
        yield Card.new({
          "set_code" => set_code,
          "set_name" => set["name"],
          "block_code" => block[0],
          "block_name" => block[1],
          "border" => set["border"],
          "releaseDate" => set["releaseDate"],
        }.merge(card_data))
      end
    end
  end

  def cards
    enum_for(:each_card).to_a
  end
end

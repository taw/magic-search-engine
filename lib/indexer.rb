# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
end

class Pathname
  def write_at(content)
    parent.mkpath
    write(content)
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

class Indexer
  def initialize
    json_path = Pathname(__dir__) + "../data/AllSets-x.json"
    @data = JSON.parse(json_path.read)
  end

  def save_all!(path)
    path = Pathname(path)
    path.parent.mkpath
    path.write(prepare_index.to_json)
  end

  def save_subset!(path, *sets)
    path = Pathname(path)
    path.parent.mkpath
    path.write(prepare_index(*sets).to_json)
  end

  def prepare_index(*set_filter)
    sets = {}
    cards = {}

    @data.each do |set_code, set_data|
      next unless set_filter.empty? or set_filter.include?(set_code)
      set_code = set_data["magicCardsInfoCode"] || set_data["code"]
      block = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
      sets[set_code] = {
        "set_code" => set_code,
        "set_name" => set_data["name"],
        "block_code" => block[0],
        "block_name" => block[1],
        "border" => set_data["border"],
        "releaseDate" => set_data["releaseDate"],
      }
      set_data["cards"].each do |card_data|
        name = card_data["name"]
        card = cards[name] ||= card_data.slice(
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
            "cmc",
            "layout",
        ).merge(
          "printings" => [],
          "legalities" => format_legalities(card_data["legalities"]),
          "colors" => format_colors(card_data["colors"]),
        )
        card["printings"] << [
          set_code,
          card_data.slice(
            "flavor",
            "artist",
            "border",
            "releaseDate",
            "rarity",
            "timeshifted",
            "watermark",
          ),
        ]
      end
    end
    {"sets"=>sets, "cards"=>cards}
  end

  def format_legalities(legalities)
    Hash[(legalities||[]).map{|leg| [leg["format"].downcase, leg["legality"].downcase]}]
  end

  def format_colors(colors)
    color_codes = {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
    (colors||[]).map{|c| color_codes.fetch(c)}
  end
end

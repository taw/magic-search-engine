require_relative "card_legality"

# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end

  def compact
    reject{|k,v| v.nil?}
  end
end

class Pathname
  def write_at(content)
    parent.mkpath
    write(content)
  end
end

MagicBlocks = [
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
  ["rav", "Ravnica", "rav", "gp", "di"],
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
    legalities = {}
    sets_code_translator = {}

    @data.each do |set_code, set_data|
      sets_code_translator[set_code] = set_data["magicCardsInfoCode"] || set_data["code"].downcase
    end

    @data.each do |set_code, set_data|
      set_code = sets_code_translator[set_code]
      next unless set_filter.empty? or set_filter.include?(set_code)

      block = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
      sets[set_code] = {
        "set_code" => set_code,
        "set_name" => set_data["name"],
        "block_code" => block[0],
        "block_name" => block[1],
        "border" => set_data["border"],
        "release_date" => format_release_date(set_data["releaseDate"]),
      }.compact

      set_data["cards"].each do |card_data|
        name = card_data["name"]

        sets_printed = card_data["printings"].map{|set_code| sets_code_translator[set_code]}
        mtgjson_legalities = format_legalities(card_data)
        algorithm_legalities = CardLegality.new(name, sets_printed, card_data["layout"], (card_data["types"] || []).map(&:downcase)).all_legalities

        if mtgjson_legalities != algorithm_legalities
          puts "FAIL #{name} #{mtgjson_legalities.sort.inspect} #{algorithm_legalities.sort.inspect}"
          require 'pry'; binding.pry
        end

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
            "reserved",
            "hand", # vanguard
            "life", # vanguard
        ).merge(
          "printings" => [],
          "colors" => format_colors(card_data["colors"]),
        ).compact
        card["printings"] << [
          set_code,
          card_data.slice(
            "flavor",
            "artist",
            "border",
            "timeshifted",
          ).merge(
            "rarity" => format_rarity(card_data["rarity"]),
            "release_date" => format_release_date(card_data["releaseDate"]),
            "watermark" => format_watermark(card_data["watermark"]),
          ).compact
        ]
      end
    end
    {"sets"=>sets, "cards"=>cards}
  end

  def format_release_date(date)
    return nil unless date
    case date
    when /\A\d{4}-\d{2}-\d{2}\z/
      date
    when /\A\d{4}-\d{2}\z/
      "#{date}-01"
    when /\A\d{4}\z/
      "#{date}-01-01"
    else
      raise "Release date format error: #{date}"
    end
  end

  def format_watermark(watermark)
    watermark && watermark.downcase
  end

  def format_rarity(rarity)
    r = rarity.downcase
    if r == "mythic rare"
      "mythic"
    else
      r
    end
  end

  def format_legalities(card_data)
    legalities = card_data["legalities"]
    return {} if card_data["layout"] == "token"
    Hash[
      (legalities||[])
      .map{|leg|
        [leg["format"].downcase, leg["legality"].downcase]
      }
      .reject{|fmt, leg|
        ["classic", "prismatic", "singleton 100", "freeform", "tribal wars legacy", "tribal wars standard"].include?(fmt)
      }
    ]
  end

  def format_colors(colors)
    color_codes = {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
    (colors||[]).map{|c| color_codes.fetch(c)}.sort.join
  end
end

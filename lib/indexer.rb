require_relative "ban_list"
require_relative "format/format"
require "date"
require "ostruct"

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

  def format_names
    [
      "commander",
      "ice age block",
      "innistrad block",
      "invasion block",
      "kamigawa block",
      "legacy",
      "lorwyn-shadowmoor block",
      "masques block",
      "mirage block",
      "mirrodin block",
      "modern",
      "odyssey block",
      "onslaught block",
      "ravnica block",
      "return to ravnica block",
      "scars of mirrodin block",
      "shards of alara block",
      "standard",
      "tarkir block",
      "tempest block",
      "theros block",
      "time spiral block",
      "un-sets",
      "urza block",
      "vintage",
      "zendikar block",
    ]
  end

  def formats
    @formats ||= Hash[
      format_names.map{|n| [n, Format[n].new]}
    ]
  end

  def algorithm_legalities_for(card_data)
    result = {}
    sets_printed = card_data["printings"].map{|set_code| @sets_code_translator[set_code]}
    card = OpenStruct.new(
      name: normalize_name(card_data["name"]),
      layout: card_data["layout"],
      printings: sets_printed.map{|set_code|
        OpenStruct.new(set_code: set_code)
      },
    )
    formats.each do |format_name, format|
      status = format.legality(card)
      result[format_name] = status if status
    end
    result
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
    @sets_code_translator = {}

    @data.each do |set_code, set_data|
      @sets_code_translator[set_code] = set_data["magicCardsInfoCode"] || set_data["code"].downcase
    end

    @data.each do |set_code, set_data|
      set_code = @sets_code_translator[set_code]
      next unless set_filter.empty? or set_filter.include?(set_code)

      block = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
      sets[set_code] = {
        "set_code" => set_code,
        "set_name" => set_data["name"],
        "block_code" => block[0],
        "block_name" => block[1],
        "border" => set_data["border"],
        "release_date" => format_release_date(set_data["releaseDate"]),
        "type" => set_data["type"],
      }.compact

      set_data["cards"].each do |card_data|
        name = card_data["name"]
        sets_printed = card_data["printings"].map{|set_code| @sets_code_translator[set_code]}
        mtgjson_legalities = format_legalities(card_data)
        # It seems incorrect
        if sets_printed == ["cns"]
          mtgjson_legalities["commander"] = mtgjson_legalities["vintage"]
        end
        algorithm_legalities = algorithm_legalities_for(card_data)

        if mtgjson_legalities != algorithm_legalities
          puts "FAIL #{name} #{mtgjson_legalities.sort.inspect} != #{algorithm_legalities.sort.inspect}"
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
            "number",
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

  def normalize_name(name)
    name.gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
  end
end

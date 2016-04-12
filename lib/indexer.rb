require_relative "ban_list"
require_relative "format/format"
require "date"
require "ostruct"
require "json"
require "set"
require "pathname"

# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end

  def compact
    reject{|k,v| v.nil?}
  end

  def map_values
    result = {}
    each do |k,v|
      result[k] = yield(v)
    end
    result
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
  ["bfz", "Battle for Zendikar", "bfz", "ogw"],
  ["soi", "Shadows over Innistrad", "soi"],
]

class Indexer
  def initialize
    json_path = Pathname(__dir__) + "../data/AllSets-x.json"
    @data = JSON.parse(json_path.read)
  end

  def format_names
    [
      "battle for zendikar block",
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
      "shadows over innistrad block",
      "standard",
      "tarkir block", # mtgjson inconsistently calls it khans of tarkir block sometimes
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

  def index_set_data(set_code, set_data)
    block = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
    if set_code == "w16"
      set_data["releaseDate"] ||= "2016-03-30"
    end
    {
      "code" => set_code,
      "name" => set_data["name"],
      "gatherer_code" => set_data["code"],
      "block_code" => block[0],
      "block_name" => block[1],
      "border" => set_data["border"],
      "release_date" => format_release_date(set_data["releaseDate"]),
      "type" => set_data["type"],
    }.compact
  end

  def index_card_data(card_data)
    # mtgjson is being silly here
    if card_data["name"] == "B.F.M. (Big Furry Monster)"
      card_data["text"] = "You must play both B.F.M. cards to put B.F.M. into play. If either B.F.M. card leaves play, sacrifice the other.\nB.F.M. can be blocked only by three or more creatures."
      card_data["cmc"] = 15
      card_data["power"] = "99"
      card_data["toughness"] = "99"
      card_data["manaCost"] = "{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}"
      card_data["types"] = ["Creature"]
      card_data["subtypes"] = ["The-Biggest-Baddest-Nastiest-Scariest-Creature-You'll-Ever-See"]
      card_data["colors"] = ["Black"]
    end
    card_data.slice(
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
      "rulings",
    ).merge(
      "printings" => [],
      "colors" => format_colors(card_data["colors"]),
    ).compact
  end

  def index_printing_data(card_data)
    if card_data["name"] == "B.F.M. (Big Furry Monster)"
      card_data["flavor"] = %Q["It was big. Really, really big. No, bigger than that. Even bigger. Keep going. More. No, more. Look, we're talking krakens and dreadnoughts for jewelry. It was big"\n-Arna Kennerd, skyknight]
    end
    card_data.slice(
      "flavor",
      "artist",
      "border",
      "timeshifted",
      "number",
      "multiverseid",
    ).merge(
      "rarity" => format_rarity(card_data["rarity"]),
      "release_date" => format_release_date(card_data["releaseDate"]),
      "watermark" => format_watermark(card_data["watermark"]),
    ).compact
  end

  def prepare_index
    sets = {}
    cards = {}
    legalities = {}
    @sets_code_translator = {}

    @data.each do |set_code, set_data|
      @sets_code_translator[set_code] = set_data["magicCardsInfoCode"] || set_data["code"].downcase
    end

    @data.each do |set_code, set_data|
      set_code = @sets_code_translator[set_code]
      sets[set_code] = index_set_data(set_code, set_data)

      ensure_set_has_card_numbers!(set_code, set_data)

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
          puts "FAIL #{name}"
          # puts "FAIL #{name} #{mtgjson_legalities.sort.inspect} != #{algorithm_legalities.sort.inspect}"
          puts "Extra formats (mtgjson):"
          puts (mtgjson_legalities.sort - algorithm_legalities.sort).map(&:inspect)
          puts "Extra formats (algo):"
          puts (algorithm_legalities.sort - mtgjson_legalities.sort).map(&:inspect)
          puts ""
        end
        card = index_card_data(card_data)
        if cards[name]
          unless card.select{|k,v| k != "printings"} == cards[name].select{|k,v| k != "printings"}
            warn "#{name} is not coherent between versions"
          end
          card = cards[name]
        else
          cards[name] = card
        end

        card["printings"] << [set_code, index_printing_data(card_data)]
      end
    end

    # Output in canonical form, to minimize diffs between mtgjson updates
    cards = Hash[cards.sort]
    cards.each do |name, card|
      card["printings"] = card["printings"].sort_by{|sc,d| [sets.keys.index(sc),d["number"],d["multiverseid"]] }
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

  # They really only have two goals:
  # * be unique
  # * allow linking to magiccards.info for debugging
  #
  # For uniqueness sake we could just allocate them ourselves easily
  # But to make them compatible instead we use mci's numbers
  #
  # For cards with multiple printings it's not obvious how to get them arranged so pics match,
  # but it's not a huge deal
  #
  # By the way ordering by multiverseid would probably be more sensible
  # (alpha starts with Ankh of Mishra, not Animate Dead), but compatibilty etc.

  def ensure_set_has_card_numbers!(set_code, set_data)
    cards = set_data["cards"]
    numbers = cards.map{|c| c["number"]}

    if numbers.compact.empty?
      use_mci_numbers!(set_code, set_data)
    end

    case set_code
    when "van"
      set_data["cards"].sort_by{|c| c["multiverseid"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
    when "pch", "arc", "pc2"
      set_data["cards"].each do |card|
        unless (card["types"] & ["Plane", "Phenomenon", "Scheme"]).empty?
          card["number"] = (1000 + card["number"].to_i).to_s
        end
      end
    when "bfz", "ogw"
      # No idea if this is correct
      basic_land_cards = set_data["cards"].select{|c| (c["supertypes"]||[]) .include?("Basic") }
      basic_land_cards = basic_land_cards.sort_by{|c| [c["number"], c["multiverseid"]]}
      basic_land_cards.each_slice(2) do |a,b|
        raise unless a["number"] == b["number"]
        b["number"] += "A"
      end
    when "rqs", "me4", "clash"
      # Just brute force, investigate later wtf?
      set_data["cards"].sort_by{|c| c["multiverseid"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
    when "st2k"
      # Just brute force, investigate later wtf?
      set_data["cards"].each_with_index{|c,i| c["number"] = "#{i+1}"}
    end

    numbers = cards.map{|c| c["number"]}
    if numbers.compact.size == 0
      warn "Set #{set_code} #{set_data["name"]} has NO numbers"
    elsif numbers.compact.size != numbers.size
      warn "Set #{set_code} #{set_data["name"]} has cards without numbers"
    end
    if numbers.compact.size != numbers.compact.uniq.size
      warn "Set #{set_code} #{set_data["name"]} has DUPLICATE numbers"
    end
  end

  # Assume that if two Forests are 100 and 101
  # then Forest with lower multiverse id gets 100
  # No idea if that's correct
  def use_mci_numbers!(set_code, set_data)
    path = Pathname(__dir__) + "../data/collector_numbers/#{set_code}.txt"
    return unless path.exist?
    mci_numbers = path.readlines.map{|line|
      number, name = line.chomp.split("\t", 2)
      [number, name.downcase]
    }.group_by(&:last).map_values{|x| x.map(&:first)}

    cards = set_data["cards"]

    if set_code == "ced" or set_code == "cedi"
      # Not on Gatherer
      cards.each do |card|
        name = card["name"]
        card["number"] = mci_numbers[name.downcase].shift
      end
    else
      mvids = cards.map{|c| [c["name"], c["multiverseid"]]}.group_by(&:first).map_values{|x| x.map(&:last).sort}
      cards.each do |card|
        name = card["name"]
        rel_idx = mvids[name].index(card["multiverseid"])
        raise unless mci_numbers[name.downcase]
        card["number"] = mci_numbers[name.downcase][rel_idx]
      end
    end
  end
end

require "date"
require "ostruct"
require "json"
require "set"
require "pathname"
require "pry"
require_relative "ban_list"
require_relative "format/format"
require_relative "indexer/card_set"
require_relative "indexer/oracle_verifier"
require_relative "indexer/foreign_names_verifier"

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
      "frontier",
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
    if card_data["names"]
      # https://github.com/mtgjson/mtgjson/issues/227
      if card_data["name"] == "B.F.M. (Big Furry Monster)"
        # just give up on this one
      elsif card_data["layout"] == "split"
        # All primary
      elsif card_data["layout"] == "double-faced"
        if card_data["manaCost"] or card_data["name"] == "Westvale Abbey"
          # Primary side
        else
          card_data["secondary"] = true
        end
      elsif card_data["layout"] == "flip"
        raise unless card_data["number"] =~ /[ab]\z/
        card_data["secondary"] = true if card_data["number"] =~ /b\z/
      elsif card_data["layout"] == "meld"
        if card_data["manaCost"] or card_data["name"] == "Hanweir Battlements"
          # Primary side
        else
          card_data["secondary"] = true
        end
      else
        binding.pry
      end
    end

    printings = card_data["printings"].map{|set_code| @sets_code_translator[set_code]}

    # arena/rep are just reprints, and some are uncards
    if printings.all?{|set_code| %W[uh ug uqc hho arena rep].include?(set_code) }
      funny = true
    else
      funny = nil
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
      "secondary",
    ).merge(
      "printings" => [],
      "colors" => format_colors(card_data["colors"]),
      "funny" => funny
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
      "release_date" => Indexer.format_release_date(card_data["releaseDate"]),
      "watermark" => format_watermark(card_data["watermark"]),
    ).compact
  end

  def report_legalities_fail(name, mtgjson_legalities, algorithm_legalities)
    @reported_fail ||= {}
    return if @reported_fail[name]
    @reported_fail[name] = true
    mtgjson_legalities = mtgjson_legalities.sort
    algorithm_legalities = algorithm_legalities.sort
    puts "FAIL #{name}"
    unless (mtgjson_legalities - algorithm_legalities).empty?
      puts "Extra formats (mtgjson):"
      puts (mtgjson_legalities - algorithm_legalities).map(&:inspect)
    end
    unless (algorithm_legalities - mtgjson_legalities).empty?
      puts "Extra formats (algo):"
      puts (algorithm_legalities - mtgjson_legalities).map(&:inspect)
    end
    puts ""
  end

  def prepare_index
    sets = {}
    cards = {}
    card_printings = {}
    @sets_code_translator = {}
    foreign_names_verifier = ForeignNamesVerifier.new
    oracle_verifier = OracleVerifier.new

    @data.each do |set_code, set_data|
      @sets_code_translator[set_code] = set_data["magicCardsInfoCode"] || set_data["code"].downcase
    end

    @data.each do |set_code, set_data|
      set_code = @sets_code_translator[set_code]
      set = Indexer::CardSet.new(set_code, set_data)
      sets[set_code] = set.to_json

      # This is fixed in new mtgjson, but we must rollback:
      set_data["cards"].each do |card_data|
        card_data["name"].gsub!("Æ", "Ae")
      end

      set.ensure_set_has_card_numbers!

      set_data["cards"].each do |card_data|
        name = card_data["name"]
        sets_printed = card_data["printings"].map{|set_code2| @sets_code_translator[set_code2]}
        mtgjson_legalities = format_legalities(card_data)
        # It seems incorrect
        if sets_printed == ["cns"] or sets_printed == ["cn2"]
          mtgjson_legalities["commander"] = mtgjson_legalities["vintage"]
        end

        if mtgjson_legalities["khans of tarkir block"]
          mtgjson_legalities["tarkir block"] = mtgjson_legalities.delete("khans of tarkir block")
        end
        algorithm_legalities = algorithm_legalities_for(card_data)

        if mtgjson_legalities != algorithm_legalities
          report_legalities_fail(name, mtgjson_legalities, algorithm_legalities)
        end
        card = index_card_data(card_data)
        oracle_verifier.add(set_code, card)
        card_printings[name] ||= []
        card_printings[name] << [set_code, index_printing_data(card_data)]
        foreign_names_verifier.add name, set_code, card_data["foreignNames"]
      end
    end

    oracle_verifier.verify!
    card_printings.each do |card_name, printings|
      cards[card_name] = oracle_verifier.canonical(card_name).merge("printings" => printings)
    end

    foreign_names_verifier.verify!
    # Link foreign names
    cards.each do |card_name, card|
      foreign_names = foreign_names_verifier.foreign_names(card_name)
      card["foreign_names"] = foreign_names if foreign_names
    end

    # This is apparently real, but mtgjson has no other side
    # http://i.tcgplayer.com/100595_200w.jpg
    [
      "Chandra, Fire of Kaladesh",
      "Jace, Vryn's Prodigy",
      "Kytheon, Hero of Akros",
      "Liliana, Heretical Healer",
      "Nissa, Vastwood Seer",
    ].each do |card_name|
      cards[card_name]["printings"].delete_if{|c,| c == "ptc"}
    end


    # Fixing printing dates of promo cards
    cards.each do |name, card|
      # Prerelease
      ptc_printing = card["printings"].find{|c,| c == "ptc" }
      # Release
      mlp_printing = card["printings"].find{|c,| c == "mlp" }
      # Gameday
      mgdc_printing = card["printings"].find{|c,| c == "mgdc" }
      # Media inserts
      mbp_printing = card["printings"].find{|c,| c == "mbp" }
      real_printings = card["printings"].select{|c,| !["ptc", "mlp", "mgdc", "mbp"].include?(c) }
      guess_date = real_printings.map{|c,d| d["release_date"] || sets[c]["release_date"] }.min
      if ptc_printing and not ptc_printing[1]["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        guess_ptc_date = (Date.parse(guess_date) - 6).to_s
        ptc_printing[1]["release_date"] = guess_ptc_date
      end
      if mlp_printing and not mlp_printing[1]["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        mlp_printing[1]["release_date"] = guess_date
      end
      if mgdc_printing and not mgdc_printing[1]["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        mgdc_printing[1]["release_date"] = guess_date
      end
      if mbp_printing and not mbp_printing[1]["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        mbp_printing[1]["release_date"] = guess_date
      end
    end

    # Output in canonical form, to minimize diffs between mtgjson updates
    cards = Hash[cards.sort]
    cards.each do |name, card|
      card["printings"] = card["printings"].sort_by{|sc,d| [sets.keys.index(sc),d["number"],d["multiverseid"]] }
    end
    # Fix DFC cmc
    cards.each do |name, card|
      next unless card["layout"] == "double-faced" and not card["cmc"]
      other_names = card["names"] - [name]
      raise "DFCs should have 2 names" unless other_names.size == 1
      other_cmc = cards[other_names[0]]["cmc"]
      if other_cmc
        card["cmc"] = other_cmc
      else
        # Westvale Abbey / Ormendahl, Profane Prince has no cmc on either side
      end
    end

    # Unfortunately mtgjson changed its mind,
    # and there's no way to distinguish front and back side of melded cards
    [
      "Brisela, Voice of Nightmares",
      "Hanweir, the Writhing Township",
      "Chittering Host",
    ].each do |melded|
      parts = cards[melded]["names"] - [melded]
      parts.each do |n|
        cards[n]["names"] -= (parts - [n])
      end
    end

    # CMC of melded card is sum of front faces
    cards.each do |name, card|
      next unless card["layout"] == "meld"
      other_names = card["names"] - [name]
      next unless other_names.size == 2 # melded side
      other_cmcs = other_names.map{|other_name| cards[other_name]["cmc"]}
      card["cmc"] = other_cmcs.compact.inject(0, &:+)
    end
    {"sets"=>sets, "cards"=>cards}
  end

  def format_watermark(watermark)
    watermark && watermark.downcase
  end

  def format_rarity(rarity)
    r = rarity.downcase
    if r == "mythic rare"
      "mythic"
    elsif r == "basic land"
      "basic"
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

  # FIXME: This really shouldn't be here
  def self.format_release_date(date)
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
end

require "date"
require "json"
require "set"
require "pathname"
require "pathname-glob"
require_relative "core_ext"
require_relative "card_set"
require_relative "oracle_verifier"
require_relative "foreign_names_verifier"
require_relative "link_related_cards_command"
require_relative "card_sets_data"
require_relative "set_code_translator"

class Indexer
  ROOT = Pathname(__dir__).parent.parent + "data"

  def initialize
    @data = CardSetsData.new
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
      elsif card_data["layout"] == "flip" or card_data["layout"] == "aftermath"
        raise unless card_data["number"] =~ /[ab]\z/
        card_data["secondary"] = true if card_data["number"] =~ /b\z/
      elsif card_data["layout"] == "meld"
        if card_data["manaCost"] or card_data["name"] == "Hanweir Battlements"
          # Primary side
        else
          card_data["secondary"] = true
        end
      else
        raise "Unknown card layout: #{card_data["layout"]}"
      end
    end

    printings = card_data["printings"].map{|set_code| set_code_translator[set_code]}

    # arena/rep are just reprints, and some are uncards
    if printings.all?{|set_code| %W[uh ug uqc hho arena rep].include?(set_code) }
      funny = true
    else
      funny = nil
    end

    # Some lands have weird nil cmc
    card_data["cmc"] ||= 0

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
      "border",
      "timeshifted",
      "number",
      "multiverseid",
    ).merge(
      "artist" => format_artist(card_data["artist"]),
      "rarity" => format_rarity(card_data["rarity"]),
      "release_date" => Indexer.format_release_date(card_data["releaseDate"]),
      "watermark" => format_watermark(card_data["watermark"]),
    ).compact
  end

  def set_code_translator
    @set_code_translator ||= SetCodeTranslator.new(@data)
  end

  def prepare_index
    sets = {}
    cards = {}
    card_printings = {}
    foreign_names_verifier = ForeignNamesVerifier.new
    oracle_verifier = OracleVerifier.new

    @data.each_set do |set_code, set_data|
      set_code = set_code_translator[set_code]
      set = Indexer::CardSet.new(set_code, set_data)
      sets[set_code] = set.to_json

      # This is fixed in new mtgjson, but we must rollback:
      set_data["cards"].each do |card_data|
        card_data["name"].gsub!("Æ", "Ae")
      end

      set.ensure_set_has_card_numbers!

      set_data["cards"].each do |card_data|
        name = card_data["name"]
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

    # Link related cards
    LinkRelatedCardsCommand.new(cards).call

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

    # Nissa loyalty https://github.com/mtgjson/mtgjson/issues/419
    # https://github.com/mtgjson/mtgjson/issues/320
    cards["Nissa, Steward of Elements"]["loyalty"] = "X"

    # Meld card numbers https://github.com/mtgjson/mtgjson/issues/420
    cards["Chittering Host"]["printings"].first.last["number"] = "96b"
    cards["Hanweir Battlements"]["printings"].first.last["number"] = "204a"

    fix_promo_printing_dates!(cards, sets)

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

    # Fix rarities of ITP/RQS from "special" to whatever they were in 4e
    # These are basically 4e precons, except with updated copyright from 1995 to 1996
    # so it's silly to treat them as some "special" printings
    cards.each do |name, card|
      next unless card["printings"].any?{|set, printing| set == "rqs" or set == "itp"}
      rarity_4e = card["printings"].find{|set, printing| set == "4e"}.last["rarity"]
      card["printings"].each do |set, printing|
        next unless set == "rqs" or set == "itp"
        printing["rarity"] = rarity_4e
      end
    end

    {"sets"=>sets, "cards"=>cards}
  end

  def fix_promo_printing_dates!(cards, sets)
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
  end

  def format_watermark(watermark)
    return unless watermark
    return if %W[White Blue Black Red Green Colorless].include?(watermark)
    watermark.downcase
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

  def format_colors(colors)
    color_codes = {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
    (colors||[]).map{|c| color_codes.fetch(c)}.sort.join
  end

  def format_artist(artist)
    artist.gsub("&amp;", "&")
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

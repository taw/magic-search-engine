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

require_relative "patches/patch"
Dir["#{__dir__}/patches/*.rb"].each do |path| require_relative path end

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
    card_data.slice(
      "name",
      "names",
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
      "display_power",
      "display_toughness",
      "power",
      "toughness"
    ).merge(
      "printings" => [],
      "colors" => format_colors(card_data["colors"]),
      "names" => card_data["names"] && card_data["names"].sort,
    ).compact
  end

  def index_printing_data(set_code, card_data)
    card_data.slice(
      "flavor",
      "border",
      "timeshifted",
      "number",
      "multiverseid",
      "artist",
      "rarity",
      "watermark",
      "exclude_from_boosters",
    ).merge(
      "release_date" => Indexer.format_release_date(card_data["releaseDate"]),
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

      set.ensure_set_has_card_numbers!

      set_data["cards"].each do |card_data|
        card_data["set_code"] = set_code
        # These aren't bugs, just normalize data into more convenient form
        PatchNormalizeRarity.new(self, card_data).call
        PatchLoyaltySymbol.new(self, card_data).call
        PatchDisplayPowerToughness.new(self, card_data).call

        # Calculate extra fields
        PatchSecondary.new(self, card_data).call
        PatchExcludeFromBoosters.new(self, card_data).call

        # Patch mtg.wtf bugs
        PatchBfm.new(self, card_data).call
        PatchUrza.new(self, card_data).call
        PatchSaga.new(self, card_data).call
        PatchCmc.new(self, card_data).call
        PatchNissa.new(self, card_data).call
        PatchMediaInsertArtists.new(self, card_data).call
        PatchCstdRarity.new(self, card_data).call
        PatchWatermarks.new(self, card_data).call
        PatchBasicLandRarity.new(self, card_data).call
        PatchUnstableBorders.new(self, card_data).call
      end

      set_data["cards"].each do |card_data|
        name = card_data["name"]
        card = index_card_data(card_data)
        oracle_verifier.add(set_code, card)
        card_printings[name] ||= []
        card_printings[name] << [set_code, index_printing_data(set_code, card_data)]
        foreign_names_verifier.add name, set_code, card_data["foreignNames"]
      end
    end

    oracle_verifier.verify!
    card_printings.each do |card_name, printings|
      cards[card_name] = oracle_verifier.canonical(card_name).merge("printings" => printings)
    end

    cards.each do |card_name, card_data|
      printings = card_data["printings"].map(&:first)
      if printings.all?{|set_code| %W[uh ug uqc hho arena rep ust].include?(set_code) }
        card_data["funny"] = true
      end
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

  def format_colors(colors)
    color_codes = {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
    (colors||[]).map{|c| color_codes.fetch(c)}.sort.join
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

require "date"
require "json"
require "set"
require "pathname"
require "pathname-glob"
require_relative "core_ext"
require_relative "card_set"
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

  def set_code_translator
    @set_code_translator ||= SetCodeTranslator.new(@data)
  end

  def prepare_index
    ### Prepare something for patches to be able to work with
    sets = {}
    cards = {}

    @data.each_set do |set_code, set_data|
      set_code = set_code_translator[set_code]
      set = Indexer::CardSet.new(set_code, set_data)
      sets[set_code] = set.to_json

      set.ensure_set_has_card_numbers!

      set_data["cards"].each do |card_data|
        name = card_data["name"]
        card_data["set_code"] = set_code
        cards[name] ||= []
        cards[name] << card_data
      end
    end

    ### Apply patches
    # These aren't bugs, just normalize data into more convenient form
    PatchNormalizeRarity.new(cards, sets).call
    PatchNormalizeColors.new(cards, sets).call
    PatchLoyaltySymbol.new(cards, sets).call
    PatchDisplayPowerToughness.new(cards, sets).call
    PatchNormalizeReleaseDate.new(cards, sets).call
    PatchNormalizeNames.new(cards, sets).call

    # Calculate extra fields
    PatchSecondary.new(cards, sets).call
    PatchExcludeFromBoosters.new(cards, sets).call
    PatchFunny.new(cards, sets).call
    PatchLinkRelated.new(cards, sets).call

    # Reconcile issues
    PatchReconcileForeignNames.new(cards, sets).call
    PatchReconcileOracle.new(cards, sets).call

    # Patch mtg.wtf bugs
    PatchSaga.new(cards, sets).call
    PatchCmc.new(cards, sets).call
    PatchNissa.new(cards, sets).call
    PatchMediaInsertArtists.new(cards, sets).call
    PatchCstdRarity.new(cards, sets).call
    PatchWatermarks.new(cards, sets).call
    PatchBasicLandRarity.new(cards, sets).call
    PatchUnstableBorders.new(cards, sets).call
    PatchEmnCardNumbers.new(cards, sets).call
    PatchItpRqsRarity.new(cards, sets).call
    PatchDeleteIncompleteCards.new(cards, sets).call

    # Not bugs, more like different judgment calls than mtgjson
    PatchBfm.new(cards, sets).call
    PatchUrza.new(cards, sets).call
    PatchFixPromoPrintDates.new(cards, sets).call
    PatchMeldCardNames.new(cards, sets).call

    ### Return data for saving
    set_order = sets.keys.each_with_index.to_h
    {
      "sets"=>sets,
      "cards"=>cards.map{|name, card_data|
        [name, index_card(card_data, set_order)]
      }.sort.to_h
    }
  end

  def index_card(card, set_order)
    common_card_data = []
    printing_data = []
    card.each do |printing|
      common_card_data << printing.slice(
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
        "toughness",
        "colors",
        "foreign_names",
        "funny",
        "related",
      ).compact

      printing_data << [
        printing["set_code"],
        printing.slice(
          "flavor",
          "border",
          "timeshifted",
          "number",
          "multiverseid",
          "artist",
          "rarity",
          "watermark",
          "exclude_from_boosters",
          "release_date",
        ).compact
      ]
    end

    result = common_card_data[0]
    name = result["name"]
    # Make sure it's reconciled at this point
    # This should be hard error once we're done
    common_card_data[1..-1].each do |other_printing|
      if other_printing != result
        warn "Data for card #{name} inconsistent"
      end
    end

    # Output in canonical form, to minimize diffs between mtgjson updates
    result["printings"] = printing_data.sort_by{|sc,d| [set_order.fetch(sc), d["number"], d["multiverseid"]] }
    result
  end
end

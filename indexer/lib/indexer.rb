require "date"
require "json"
require "set"
require "pathname"
require "pathname-glob"
require_relative "core_ext"
require_relative "card_sets_data"

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

  def set_code_translator
    @set_code_translator ||= SetCodeTranslator.new(@data)
  end

  def apply_patches(cards, sets)
    [
      # Each set needs unique code, by convention all lowercase
      PatchSetCodes,

      # All cards absolutely need unique numbers
      PatchFixCollectorNumbers,
      PatchUseMciNumbersAsFallback,
      PatchBattlebond,
      PatchVerifyCollectorNumbers,

      # Normalize data into more convenient form
      PatchNormalizeRarity,
      PatchNormalizeColors,
      PatchLoyaltySymbol,
      PatchDisplayPowerToughness,
      PatchNormalizeReleaseDate,
      PatchNormalizeNames,

      # Calculate extra fields
      PatchBlocks,
      PatchHasBoosters,
      PatchSecondary,
      PatchExcludeFromBoosters,
      PatchFunny,
      PatchLinkRelated,

      # Reconcile issues
      PatchReconcileForeignNames,
      PatchReconcileOnSetPriority,

      # Patch mtg.wtf bugs
      PatchSaga,
      PatchCmc,
      PatchNissa,
      PatchMediaInsertArtists,
      PatchCstdRarity,
      PatchWatermarks,
      PatchBasicLandRarity,
      PatchUnstableBorders,
      PatchEmnCardNumbers,
      PatchItpRqsRarity,
      PatchDeleteIncompleteCards,

      # Not bugs, more like different judgment calls than mtgjson
      PatchBfm,
      PatchUrza,
      PatchFixPromoPrintDates,
      PatchMeldCardNames,
    ].each do |patch_class|
      patch_class.new(cards, sets).call
    end
  end

  def prepare_index
    ### Prepare something for patches to be able to work with
    sets = []
    cards = {}

    @data.each_set do |set_code, set_data|
      set = set_data.slice(
        "name",
        "border",
        "type",
        "booster",
        "custom",
        "releaseDate",
      ).merge(
        "code" => set_data["magicCardsInfoCode"],
        "gatherer_code" => set_data["code"],
        "online_only" => set_data["onlineOnly"],
      ).compact
      sets << set
      # FIXME: original_order is needed until we fix rqs and st2k
      set_data["cards"].each_with_index do |card_data, i|
        name = card_data["name"]
        card_data["set"] = set
        card_data["original_order"] = i
        (cards[name] ||= []) << card_data
      end
    end

    ### Apply patches
    apply_patches(cards, sets)

    ### Return data for saving
    sets = sets.map{|s| [s["code"], s]}.to_h
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

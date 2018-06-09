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

  # In verbose mode we validate each patch to make sure it actually does something
  def initialize(save_path, verbose=false)
    @save_path = Pathname(save_path)
    @verbose = verbose
    @data = CardSetsData.new
  end

  def call
    @save_path.parent.mkpath
    @save_path.write(prepare_index.to_json)
  end

  private

  def prepare_index
    ### Prepare something for patches to be able to work with
    sets, cards = load_database

    ### Apply patches
    apply_patches(cards, sets)

    ### Return data for saving
    sets = sets.map{|s| [s["code"], index_set(s)]}.to_h
    set_order = sets.keys.each_with_index.to_h
    {
      "sets" => sets,
      "cards" => cards.map{|name, card_data|
        [name, index_card(card_data, set_order)]
      }.sort.to_h
    }
  end

  def index_set(set)
    set.slice(
      "name",
      "border",
      "type",
      "booster",
      "custom",
      "release_date",
      "code",
      "gatherer_code",
      "online_only",
      "has_boosters",
      "block_code",
      "block_name",
      "gatherer_block_code",
      "originalText",
      "originalType",
    )
  end

  def patches
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
      PatchAssignPrioritiesToSets,
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
    ]
  end

  def apply_patches(cards, sets)
    patches.each do |patch_class|
      if @verbose
        # This is very slow, and some patches are just here to verify things
        # It could still be useful for debugging
        before = Marshal.load(Marshal.dump([cards, sets]))
        patch_class.new(cards, sets).call
        if before == [cards, sets]
          warn "Patch #{patch_class} seems to be doing nothing"
        end
      else
        patch_class.new(cards, sets).call
      end
    end
  end

  def load_database
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
      set_data["cards"].each_with_index do |card_data, i|
        name = card_data["name"]
        card_data["set"] = set
        (cards[name] ||= []) << card_data
      end
    end
    return sets, cards
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

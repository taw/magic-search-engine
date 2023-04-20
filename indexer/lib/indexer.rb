require "pry"
require "date"
require "json"
require "set"
require "pathname"
require "pathname-glob"
require_relative "core_ext"
require_relative "card_sets_data"
require_relative "index_serializer"
require_relative "products_serializer"
require_relative "uuids_serializer"
require_relative "decks_serializer"
require_relative "deck_printing_resolver"

require_relative "patches/patch"
Dir["#{__dir__}/patches/*.rb"].each do |path| require_relative path end

class Indexer
  ROOT = Pathname(__dir__).parent.parent + "data"
  INDEX_ROOT = Pathname(__dir__).parent.parent + "index"

  # In verbose mode we validate each patch to make sure it actually does something
  def initialize(verbose=false)
    @save_path = INDEX_ROOT + "index.json"
    @uuids_path = INDEX_ROOT + "uuids.txt"
    @products_path = INDEX_ROOT + "products.txt"
    @decks_path = INDEX_ROOT + "deck_index.json"
    @verbose = verbose
    @data = CardSetsData.new
  end

  def call
    @save_path.parent.mkpath
    load_database
    load_decks
    apply_patches
    @save_path.write(IndexSerializer.new(@sets, @cards, @products).to_s)
    @uuids_path.write(UuidsSerializer.new(@cards).to_s)
    @products_path.write(ProductsSerializer.new(@products).to_s)
    @decks_path.write(DecksSerializer.new(@decks).to_s)
  end

  private

  def patches
    [
      # Load data
      PatchTokens,
      # For transition period we support any mix of mtgjson v3 and v4
      PatchMtgjsonVersions,
      # Each set needs unique code, by convention all lowercase
      PatchSetCodes,
      PatchRemoveEmptySets,
      PatchReleaseDates,

      # This renames cards so it needs to be done early
      PatchPlaytestCards,

      # All cards absolutely need unique numbers
      PatchMultipartCardNumbers,
      PatchVerifyCollectorNumbers,

      # Normalize data into more convenient form
      PatchNormalizeColors,
      PatchDisplayPowerToughness,
      PatchNormalizeReleaseDate,
      PatchManaCost,

      # Patch mtg.wtf bugs - these need to happen early to support patches below
      PatchMeld,
      PatchBasicLandRarity,
      PatchRaritySpecial,
      PatchBaseSize,

      # Calculate extra fields
      PatchBlocks,
      PatchHasBoosters,
      PatchSecondary,
      PatchVariantMisprint,
      PatchVariantForeign,
      PatchExcludeFromBoosters,
      PatchFoiling,
      PatchSetTypes,
      PatchFunny,
      PatchLinkRelated,
      PatchColorshifted,
      PatchPrintSheets,
      PatchMB1,
      PatchABUR,
      PatchNewPrintSheets,
      PatchFrame,
      PatchPartner,
      PatchBfm,
      PatchUnfinity, # before UST
      PatchUnstable,
      PatchShandalar,
      PatchXmage,
      PatchCommander,
      PatchMultipart,
      PatchSubsets,

      # Patch more mtg.wtf bugs
      PatchAeLigature, # is this even needed anymore?
      PatchFlipCardManaCost,
      PatchArtistNames,

      # Reconcile issues
      PatchReconcileForeignNames,
      PatchAssignPrioritiesToSets,
      PatchReconcileOnSetPriority,
      PatchDeleteErrataSets,

      # Not bugs, more like different judgment calls than mtgjson
      PatchUrza,

      # One more round of normalization, it throws away some information
      PatchNormalizeNames,

      # Deck Indexer
      PatchDecks,
    ]
  end

  def apply_patches
    patches.each do |patch_class|
      if @verbose
        # This is very slow, and some patches are just here to verify things
        # It could still be useful for debugging
        before = Marshal.load(Marshal.dump([@cards, @sets, @decks]))
        patch_class.new(@cards, @sets, @decks).call
        if before == [@cards, @sets, @decks]
          warn "Patch #{patch_class} seems to be doing nothing"
        end
      else
        patch_class.new(@cards, @sets, @decks).call
      end
    end
  end

  def load_database
    @sets = []
    @cards = {}
    @products = []

    @data.each_set do |set_code, set_data|
      set = set_data.slice(
        "border",
        "custom",
        "meta",
        "name",
        "releaseDate",
        "tokens",
        "type",
      ).merge(
        "official_code" => set_data["code"],
        "online_only" => (set_data["onlineOnly"] || set_data["isOnlineOnly"]) ? true : nil,
        "base_set_size" => set_data["baseSetSize"],
      ).compact
      @sets << set
      set_data["cards"].each_with_index do |card_data, i|
        name = card_data["name"]
        card_data["set"] = set
        (@cards[name] ||= []) << card_data
      end
      (set_data["sealedProduct"] || []).each do |product|
        @products << product.except("identifiers", "purchaseUrls").merge("set_code" => set_code.downcase).compact
      end
    end
  end

  def load_decks
    @decks = JSON.parse((ROOT + "decks.json").read)
  end
end

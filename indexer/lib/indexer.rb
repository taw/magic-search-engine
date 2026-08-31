require "date"
require "json"
require "pathname"
require "pry"
require "set"
require_relative "card_sets_data"
require_relative "core_ext"
require_relative "deck_printing_resolver"
require_relative "decks_serializer"
require_relative "index_serializer"
require_relative "mtgo_ids_serializer"
require_relative "products_serializer"
require_relative "scryfall_ids_serializer"
require_relative "token_uuids_serializer"
require_relative "uuids_serializer"

require_relative "patches/patch"
Dir["#{__dir__}/patches/*.rb"].each do |path| require_relative path end

class Indexer
  ROOT = Pathname(__dir__) + "../../data"
  SETS_ROOT = Pathname(__dir__) + "../../../magic-search-engine-data/data/sets"
  INDEX_ROOT = Pathname(__dir__) + "../../index"

  # In verbose mode we validate each patch to make sure it actually does something
  def initialize(verbose=false)
    @sets_path = INDEX_ROOT + "sets.json"
    @cards_path = INDEX_ROOT + "cards.jsonl"
    @uuids_path = INDEX_ROOT + "uuids.txt"
    @token_uuids_path = INDEX_ROOT + "token_uuids.txt"
    @scryfall_ids_path = INDEX_ROOT + "scryfall_ids.txt"
    @mtgo_ids_path = INDEX_ROOT + "mtgo_ids.txt"
    @products_path = INDEX_ROOT + "products.json"
    @decks_path = INDEX_ROOT + "deck_index.json"
    @verbose = verbose
    @data = CardSetsData.new
  end

  def call
    unless SETS_ROOT.exist?
      warn "Could not find sets data, expected at #{SETS_ROOT}"
      exit 1
    end

    INDEX_ROOT.mkpath
    load_database
    load_decks
    apply_patches
    index = IndexSerializer.new(@sets, @cards, @products)
    @sets_path.write(index.sets_json)
    @cards_path.write(index.cards_jsonl)
    @uuids_path.write(UuidsSerializer.new(@cards).to_s)
    @token_uuids_path.write(TokenUuidsSerializer.new(@tokens).to_s)
    @scryfall_ids_path.write(ScryfallIdsSerializer.new(@cards).to_s)
    @mtgo_ids_path.write(MtgoIdsSerializer.new(@cards).to_s)
    @products_path.write(ProductsSerializer.new(@products).to_s)
    @decks_path.write(DecksSerializer.new(@decks).to_s)
  end

  def inspect
    "#{self.class}"
  end

  private

  def patches
    [
      # Load data
      PatchTokens,

      # Every card rename happens here, before anything indexes cards by name
      PatchCardNames,

      # Patch mtgjson bugs, while its own field names are still around
      PatchMtgjsonBugs,

      # Translate mtgjson's field names and value formats into ours
      PatchMtgjsonFields,
      PatchTextCleanup,
      # Splits reversible cards apart, so it must precede the number checks
      PatchReversibleCards,

      # Each set needs unique code, by convention all lowercase
      PatchSetCodes,
      PatchMB1,
      PatchRemoveEmptySets,
      PatchReleaseDates,

      # All cards absolutely need unique numbers
      PatchMultipartCardNumbers,
      PatchVerifyCollectorNumbers,

      # Normalize data into more convenient form
      PatchNormalizeColors,
      PatchDisplayPowerToughness,
      PatchNormalizeReleaseDate,
      PatchSetLanguages,

      # Patch mtg.wtf bugs - these need to happen early to support patches below
      PatchMeld,
      PatchBasicLandRarity,
      PatchRaritySpecial,
      PatchBaseSize,

      # Calculate extra fields
      PatchAlchemy,
      PatchBlocks,
      PatchSecondary,
      PatchVariantArena, # before VariantMisprint
      PatchVariantMisprint,
      PatchVariantForeign,
      PatchFoiling,
      PatchSetTypes,
      PatchFunny,
      PatchSpecialFormat,
      PatchNonTournament,
      PatchSpellbook, # before LinkRelated
      PatchSpecialize, # before LinkRelated
      PatchLinkRelated,
      PatchColorshifted,
      PatchPrintSheets,
      PatchABUR,
      PatchNewPrintSheets,
      PatchMultiPrintSheets,
      PatchFrame,
      PatchPartner,
      PatchBfm,
      PatchUnfinity, # before Unstable
      PatchUnstable,
      PatchShandalar,
      PatchIsDreamcast,
      PatchXmage,
      PatchCommander,
      PatchMultipart,
      PatchSubsets,
      PatchDeckLimit,
      PatchProduces,

      # Patch more mtg.wtf bugs
      PatchFlipCardManaCost,
      PatchArtistNames,

      # Reconcile issues
      PatchReconcileForeignNames,
      PatchAssignPrioritiesToSets,
      PatchReconcileOnSetPriority,
      PatchDeleteErrataSets,

      # Not bugs, more like different judgment calls than mtgjson
      PatchUrza,

      # Needs final reconciled text
      PatchShortName,

      # Needs final set codes, numbers, and names
      PatchMtgoIds,


      # Deck Indexer
      PatchDecks,

      # Products Indexer
      PatchProducts,
    ]
  end

  def apply_patches
    patches.each do |patch_class|
      if @verbose
        # This is very slow, and some patches are just here to verify things
        # It could still be useful for debugging
        before = Marshal.load(Marshal.dump([@cards, @sets, @decks, @products]))
        patch_class.new(@cards, @sets, @decks, @products).call
        if before == [@cards, @sets, @decks, @products]
          warn "Patch #{patch_class} seems to be doing nothing"
        end
      else
        patch_class.new(@cards, @sets, @decks, @products).call
      end
    end
  end

  def load_database
    @sets = []
    @cards = {}
    @products = []
    @tokens = []

    @data.each_set do |set_code, set_data|
      set = set_data.slice(
        "border",
        "custom",
        "languages",
        "meta",
        "name",
        "releaseDate",
        "tokens",
        "type",
      ).merge(
        "official_code" => set_data["code"],
        "online_only" => (set_data["onlineOnly"] || set_data["isOnlineOnly"]) ? true : nil,
        "base_set_size" => set_data["baseSetSize"],
        "partial_preview" => set_data["isPartialPreview"],
        "token_set_code" => set_data["tokenSetCode"]&.downcase,
        "mtgo_code" => set_data["mtgoCode"],
      ).compact
      @sets << set
      set_data["cards"].each do |card_data|
        name = card_data["name"]
        card_data["set"] = set
        (@cards[name] ||= []) << card_data
      end
      set_data["tokens"].each do |token|
        # There's no token name uniqueness
        token["set"] = set
        @tokens << token
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

class CardSet
  attr_reader :name, :code, :alternative_code
  attr_reader :block_name, :block_code, :alternative_block_code
  attr_reader :border, :release_date, :printings, :types
  attr_reader :decks, :base_set_size
  attr_reader :products, :subsets, :languages
  attr_reader :limited_formats
  attr_reader :token_set_code
  attr_reader :normalized_name, :normalized_name_alt

  # Set by CardDatabase initialization, sets ordered by name
  attr_accessor :name_sort_index

  def initialize(db, data)
    @db = db
    @name          = data["name"]
    @code          = data["code"]
    @alternative_code = data["alternative_code"]
    @block_name    = data["block_name"]
    @block_code    = data["block_code"]&.downcase
    @alternative_block_code = data["alternative_block_code"]&.downcase
    @border        = data["border"]
    @types         = data["types"]
    @release_date  = data["release_date"] && Date.parse(data["release_date"])
    @printings     = []
    @online_only   = !!data["online_only"]
    @custom        = !!data["custom"]
    @funny         = !!data["funny"]
    @decks         = []
    @base_set_size = data["base_set_size"]
    @products = []
    @limited_formats = []
    @subsets = data["subsets"]
    @languages = data["languages"]
    @token_set_code = data["token_set_code"]

    # caches
    @normalized_name = normalize_set_name(@name)
    @normalized_name_alt = normalize_set_name_alt(@name)
  end

  def printing_by_number
    @printing_by_number ||= @printings.to_h{|printing| [printing.number, printing] }
  end

  def has_individual_card_release_dates?
    @printings.any?{|c| c.release_date != @release_date}
  end

  def individual_card_release_dates
    @printings.map(&:release_date).minmax
  end

  def cards_in_precons
    @db.cards_in_precons[@code]
  end

  def online_only?
    @online_only
  end

  def custom?
    !!@custom
  end

  def funny?
    !!@funny
  end

  # counting MH1 in addition to core sets and expansions
  def regular?
    @types.include?("standard") or @types.include?("modern")
  end

  include Comparable

  def <=>(other)
    name_sort_index <=> other.name_sort_index
  end

  def hash
    @code.hash
  end

  def deck_named(name)
    @decks.find{|d| d.name == name}
  end

  def physical_cards(foil=false)
    @printings
      .select do |card|
        if foil
          card.any_foil?
        else
          card.has_finish?(:nonfoil)
        end
      end
      .map do |card|
        PhysicalCard.for(card, foil: foil)
      end
      .uniq
  end

  def physical_card_names
    [*physical_cards(true), *physical_cards(false)].map(&:name).uniq
  end

  def physical_cards_in_boosters(foil=false)
    physical_cards(foil).select(&:in_boosters?)
  end

  def inspect
    "CardSet[#{@code}, #{@name}]"
  end

  private
  # copied from CardDatabase
  def normalize_text(text)
    text.downcase.normalize_accents.strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end

  def normalize_set_name(name)
    normalize_text(name).downcase.gsub("'s", "s").split(/[^a-z0-9]+/).join(" ")
  end

  def normalize_set_name_alt(name)
    normalize_text(name).downcase.gsub("'s", "").split(/[^a-z0-9]+/).join(" ")
  end
end

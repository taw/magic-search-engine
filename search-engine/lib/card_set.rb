class CardSet
  attr_reader :name, :code, :alternative_code, :gatherer_code
  attr_reader :block_name, :block_code, :alternative_block_code
  attr_reader :border, :release_date, :printings, :type
  attr_reader :decks

  def initialize(db, data)
    @db = db
    @name          = data["name"]
    @code          = data["code"]
    @alternative_code = data["alternative_code"]
    @gatherer_code = data["gatherer_code"]
    @block_name    = data["block_name"]
    @block_code    = data["block_code"]&.downcase
    @alternative_block_code = data["alternative_block_code"]&.downcase
    @border        = data["border"]
    @type          = data["type"]
    @release_date  = data["release_date"] && Date.parse(data["release_date"])
    @printings     = Set[]
    @online_only   = !!data["online_only"]
    @has_boosters  = !!data["has_boosters"]
    @in_other_boosters = !!data["in_other_boosters"]
    @custom        = !!data["custom"]
    @decks         = []
  end

  def cards_in_precons
    @db.cards_in_precons[@code]
  end

  def has_boosters?
    @has_boosters
  end

  def in_other_boosters?
    @in_other_boosters
  end

  def online_only?
    @online_only
  end

  def custom?
    !!@custom
  end

  def regular?
    @type == "core" or @type == "expansion"
  end

  include Comparable
  def <=>(other)
    @code <=> other.code
  end

  def hash
    @code.hash
  end

  def physical_cards(foil=false)
    @printings
      .select do |card|
        if foil
          card.foiling != "nonfoil"
        else
          card.foiling != "foilonly"
        end
      end
      .map do |card|
        PhysicalCard.for(card, foil)
      end
      .uniq
  end

  def physical_card_names
    [*physical_cards(true), *physical_cards(false)].map(&:name).uniq
  end

  def physical_cards_in_boosters(foil=false)
    physical_cards(foil).select(&:in_boosters?)
  end
end

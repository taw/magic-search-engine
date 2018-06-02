class CardSet
  attr_reader :name, :code, :gatherer_code
  attr_reader :block_name, :block_code, :gatherer_block_code
  attr_reader :border, :release_date, :printings, :type
  attr_reader :decks

  def initialize(data)
    @name          = data["name"]
    @code          = data["code"]
    @gatherer_code = data["gatherer_code"]
    @block_name    = data["block_name"]
    @block_code    = data["block_code"]&.downcase
    @gatherer_block_code = data["gatherer_block_code"]&.downcase
    @border        = data["border"]
    @type          = data["type"]
    @release_date  = data["release_date"] && Date.parse(data["release_date"])
    @printings     = Set[]
    @online_only   = !!data["online_only"]
    @has_boosters  = !!data["has_boosters"]
    @decks         = []
  end

  def has_boosters?
    @has_boosters
  end

  def online_only?
    @online_only
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
    @printings.map do |card|
      PhysicalCard.for(card, foil)
    end.uniq
  end

  def physical_cards_in_boosters(foil=false)
    physical_cards(foil).select(&:in_boosters?)
  end
end

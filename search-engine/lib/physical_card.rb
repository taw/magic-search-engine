class PhysicalCard
  # A physical card is one printing's main front plus a finish. Every other
  # face it has follows from the main front, so none of them are stored.
  attr_reader :main_front, :foil, :etched
  def initialize(main_front, foil, etched)
    @main_front = main_front
    @foil = !!foil
    @etched = !!etched
  end

  def front
    @main_front.physical_front_parts
  end

  def back
    @main_front.physical_back_parts
  end

  def name
    if @main_front.has_multiple_parts?
      front.map(&:name).join(" // ")
    else
      @main_front.name
    end
  end

  def flavor_name
    if @main_front.flavor_name
      front.map(&:flavor_name).join(" // ")
    end
  end

  def name_slug
    @main_front.name_slug
  end

  def back_name
    back.map(&:name).join(" // ")
  end

  def to_s
    name
  end

  def inspect
    back_parts = back
    [
      "PhysicalCard[",
      name,
      back_parts.empty? ? "" : "; #{back_parts.map(&:name).join(" // ")}}",
      "; #{set_code}/#{number}",
      foil ? "; foil" : "",
      etched ? "; etched" : "",
      "]",
    ].join
  end

  # A lot of things can be forwarded to main_front

  def set
    main_front.set
  end

  def set_code
    main_front.set.code
  end

  def in_boosters?
    main_front.in_boosters?
  end

  def color_identity
    main_front.color_identity
  end

  def allowed_in_any_number?
    main_front.allowed_in_any_number?
  end

  def decklimit
    main_front.decklimit
  end

  def commander?
    main_front.commander?
  end

  def brawler?
    main_front.brawler?
  end

  def partner?
    main_front.partner?
  end

  def partner
    main_front.partner
  end

  def valid_partner_for?(other)
    main_front.valid_partner_for?(other.main_front)
  end

  def rarity
    main_front.rarity
  end

  def type_group
    main_front.type_group
  end

  # Deck pages show one card of the deck as a big picture. Without a commander
  # to point at, the most interesting card is the best guess - a mythic
  # planeswalker beats a rare creature beats yet another Mountain.
  def preview_score
    types = main_front.types
    score = 0
    score += 10000 if rarity == "mythic"
    score += 1000 if rarity == "rare"
    score += 100 if types.include?("planeswalker")
    score += 10 if types.include?("legendary")
    score += 1 if types.include?("creature")
    score
  end

  def self.best_preview(cards)
    cards.min_by{|card| [-card.preview_score, card.name]}
  end

  def oversized
    main_front.oversized
  end

  def number
    main_front.number
  end

  # We number each face of a multipart card separately, Gatherer style (10a / 10b),
  # but exports which follow Scryfall convention want just one number per physical card.
  # Those numbers are just the mtgjson number with a letter appended by the indexer,
  # so dropping that letter recovers it. The main front always got "a" appended;
  # reversible cards are two separate physical cards sharing a number, so either letter.
  def physical_card_number
    number = main_front.number
    if main_front.promo_types&.include?("reversiblefront") or main_front.promo_types&.include?("reversibleback")
      number.sub(/[ab]\z/, "")
    elsif main_front.has_multiple_parts?
      number.sub(/a\z/, "")
    else
      number
    end
  end

  def number_i
    main_front.number_i
  end

  def number_sort_index
    main_front.number_sort_index
  end

  def arena?
    main_front.arena?
  end

  def paper?
    main_front.paper?
  end

  def mtgo?
    main_front.mtgo?
  end

  def parts
    [*front, *back]
  end

  def ==(other)
    other.instance_of?(PhysicalCard) and sort_key == other.sort_key
  end

  def eql?(other)
    self == other
  end

  include Comparable
  def <=>(other)
    sort_key <=> other.sort_key
  end

  def sort_key
    @main_front.default_sort_index * 4 + (foil ? 2 : 0) + (etched ? 1 : 0)
  end

  # Agrees with `==` by construction, as both are the sort key. That matters:
  # `default_sort_index` is unique per printing, so the key identifies the card.
  def hash
    sort_key
  end

  def self.for(card, foil=false, etched=false)
    new(card.main_front, foil, etched)
  end
end

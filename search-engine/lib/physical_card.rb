class PhysicalCard
  # Only meld and multipart cards have a back, so the great majority of these
  # objects would otherwise hold an empty array each, all of them alike.
  NO_BACK = [].freeze

  attr_reader :front, :back, :foil, :etched, :hash
  def initialize(front, back, foil, etched)
    @front = front
    @back = back.empty? ? NO_BACK : back
    @foil = !!foil
    @etched = !!etched
    @hash = [main_front, foil, etched].hash
  end

  def name
    @front.map(&:name).join(" // ")
  end

  def flavor_name
    if @front[0].flavor_name
      @front.map(&:flavor_name).join(" // ")
    end
  end

  def name_slug
    main_front.name_slug
  end

  def back_name
    @back.map(&:name).join(" // ")
  end

  def to_s
    name
  end

  def inspect
    [
      "PhysicalCard[",
      name,
      @back != [] ? "; #{back_name}}" : "",
      "; #{set_code}/#{number}",
      foil ? "; foil" : "",
      etched ? "; etched" : "",
      "]",
    ].join
  end

  def main_front
    @front[0]
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
    [*@front, *@back]
  end

  # @front[0] uniquely determines @front / @back
  # as does any non-nil @front[i]
  # @back[0] doesn't, as two different meld cards can have same CardPrinting on the back
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
    main_front.default_sort_index * 4 + (foil ? 2 : 0) + (etched ? 1 : 0)
  end

  def self.for(card, foil=false, etched=false)
    # meld really doesn't fit this model, as we have one CardPrinting that's on two physical card backs
    # just fake something that works
    if card.back? and card.layout == "meld"
      self.for(card.others[0], foil, etched)
    elsif !card.has_multiple_parts? or card.name == "B.F.M. (Big Furry Monster)" or card.name == "B.F.M. (Big Furry Monster, Right Side)"
      PhysicalCard.new([card], [], foil, etched)
    else
      front_parts, back_parts = [card, *card.others].partition(&:front?)
      front_parts = front_parts.sort_by(&:number)
      back_parts = back_parts.sort_by(&:number)
      PhysicalCard.new(front_parts, back_parts, foil, etched)
    end
  end
end

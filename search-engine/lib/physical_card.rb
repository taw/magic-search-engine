class PhysicalCard
  attr_reader :front, :back, :foil
  def initialize(front, back, foil)
    @front = front
    @back = back
    @foil = !!foil
  end

  def name
    @front.map(&:name).join(" // ")
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

  def number
    main_front.number
  end

  def number_i
    main_front.number_i
  end

  def parts
    [*@front, *@back]
  end

  # @front[0] uniquely determines @front / @back
  # as does any non-nil @front[i]
  # @back[0] doesn't, as two different meld cards can have same CardPrinting on the back
  def ==(other)
    other.instance_of?(PhysicalCard) and main_front == other.main_front and foil == other.foil
  end

  def hash
    [main_front, foil].hash
  end

  def eql?(other)
    self == other
  end

  include Comparable
  def <=>(other)
    [main_front, foil ? 1 : 0] <=> [other.main_front, other.foil ? 1 : 0]
  end

  def self.for(card, foil=false)
    # meld really doesn't fit this model, as we have one CardPrinting that's on two physical card backs
    # just fake something that works
    if card.back? and card.layout == "meld"
      self.for(card.others[0], foil)
    elsif !card.has_multiple_parts? or card.name == "B.F.M. (Big Furry Monster)" or card.name == "B.F.M. (Big Furry Monster, Right Side)"
      PhysicalCard.new([card], [], foil)
    else
      front_parts, back_parts = [card, *card.others].partition(&:front?)
      front_parts = front_parts.sort_by(&:number)
      back_parts = back_parts.sort_by(&:number)
      PhysicalCard.new(front_parts, back_parts, foil)
    end
  end
end

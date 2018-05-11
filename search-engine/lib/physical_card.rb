class PhysicalCard
  attr_reader :front, :back, :foil
  def initialize(front, back, foil)
    @front = front
    @back = back
    @foil = foil
  end

  def name
    @front.map(&:name).join(" // ")
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

  def in_boosters?
    main_front.in_boosters?
  end

  def rarity
    main_front.rarity
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

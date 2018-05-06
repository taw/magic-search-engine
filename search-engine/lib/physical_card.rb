class PhysicalCard
  attr_reader :front, :back, :foil
  def initialize(front, back, foil)
    @front = front
    @back = back
    @foil = foil
  end

  def to_s
    @front.map(&:name).join(" // ")
  end

  def main_front
    @front[0]
  end

  # @front[0] uniquely determines @front / @back
  def ==(other)
    other.instance_of?(PhysicalCard) and main_front == other.main_front and foil == other.foil
  end

  def hash
    [main_front, foil].hash
  end

  def eql?(other)
    self == other
  end

  def self.for(card, foil)
    # meld really doesn't fit this model, as we have one CardPrinting that's on two physical card backs
    # just fake something that works
    if card.back? and card.layout == "meld"
      # binding.pry
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

require_relative "pack"

class Sealed
  def initialize(db, *pack_descriptors)
    @packs = []
    pack_descriptors.each do |descriptor|
      if descriptor =~ /\A(\d+)x(.*)/
        @packs << [$1.to_i, Pack[db, $2]]
      else
        @packs << [1, Pack[db, descriptor]]
      end
    end
  end

  def call
    cards = []
    @packs.each do |count, pack|
      count.times do 
        cards.push *pack.open
      end
    end
    cards
  end
end

# Shares nothing with Pack except some testing stuff
class WeightedPack < Pack
  # Takes Hash<Pack, Integer>
  def initialize(packs)
    @packs = packs
    @total_weight = @packs.values.inject(0, &:+)
  end

  def open
    random_number = rand(@total_weight)
    @packs.each do |pack, weight|
      random_number -= weight
      return pack.open if random_number < 0
    end
    raise "Weighted sample algorithm failed"
  end

  ## Testing support

  def expected_values
    result = Hash.new(0)
    @packs.each do |pack, weight|
      pack.expected_values.each do |card, card_ev|
        result[card] += card_ev * Rational(weight, @total_weight)
      end
    end
    result
  end
end

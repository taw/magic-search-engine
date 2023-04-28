# Shares nothing with Pack except some testing stuff
class WeightedPack < Pack
  # Takes Hash<Pack, Integer>
  # If any key is WeightedPack, the whole structure is flattened
  def initialize(packs)
    @packs = packs
    if @packs.keys.any?{ |pack| pack.is_a?(WeightedPack) }
      flatten!
    end
    gcd = @packs.values.reduce(&:gcd)
    @packs.each do |pack, weight|
      @packs[pack] = weight / gcd
    end
    @total_weight = @packs.values.sum
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

  attr_reader :packs, :total_weight

  def expected_values
    result = Hash.new(0)
    @packs.each do |pack, weight|
      pack.expected_values.each do |card, card_ev|
        result[card] += card_ev * Rational(weight, @total_weight)
      end
    end
    result
  end

  def cards
    @packs.keys.flat_map(&:cards).uniq
  end

  private

  def flatten!
    result = Hash.new(0)
    @packs.each do |pack, weight|
      if pack.is_a?(WeightedPack)
        pack.packs.each do |subpack, subweight|
          result[subpack] = Rational(weight * subweight, pack.total_weight)
        end
      else
        result[pack] = weight
      end
    end
    lcm = result.values.map(&:denominator).inject(&:lcm)
    result = result.map do |pack, weight|
      weight *= lcm
      raise unless weight.to_i == weight
      [pack, weight.to_i]
    end.to_h
    @packs = result
  end
end

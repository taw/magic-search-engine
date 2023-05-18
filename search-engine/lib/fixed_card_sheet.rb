class FixedCardSheet < CardSheet
  # weights are not just probabilities, they determine total size of the pack as well
  # weight [1] and [2] are completely different
  def initialize(elements, weights=nil)
    @elements = elements
    if weights.nil?
      @weights = @elements.map { |card| 1 }
    else
      @weights = weights
    end
    @total_weight = @weights.sum
  end

  def random_cards_without_duplicates(count)
    raise "Fixed card sheets only support getting exactly the same number of cards" unless count == @total_weight
    # we could shuffle it, but there's not much point
    cards.zip(weights).flat_map{|c,w| [c]*w}
  end
end

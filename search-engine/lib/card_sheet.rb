# CardSheet is collection of CardSheet and PhysicalCard elements
class CardSheet
  attr_reader :elements, :weights, :total_weight

  def initialize(elements, weights=nil)
    @elements = elements
    @weights = weights
    if @weights
      @total_weight = @weights.sum
    else
      @total_weight = @elements.size
    end
  end

  def random_card
    if @weights
      random_number = rand(@total_weight)
      result = @weights.each_with_index do |w, i|
        random_number -= w
        break @elements[i] if random_number < 0
      end
      raise "Weighted sample algorithm failed" unless result
    else
      result = @elements.sample
    end
    if result.is_a?(CardSheet)
      result.random_card
    else
      result
    end
  end

  # This is as far as our collation emulation goes
  # FIXME: We should check we're not infinite looping here
  def random_cards_without_duplicates(count)
    result = Set[]
    count.times do
      card = random_card
      redo if result.include?(card)
      result << card
    end
    result.to_a
  end

  ### Testing support

  def cards
    @elements.flat_map do |element|
      if element.is_a?(CardSheet)
        element.cards
      else
        [element]
      end
    end.uniq
  end

  def probabilities
    result = Hash.new(Rational(0,1))
    @elements.each_with_index do |element, i|
      if @weights
        probability = Rational(@weights[i], @total_weight)
      else
        probability = Rational(1, @total_weight)
      end
      if element.is_a?(CardSheet)
        element.probabilities.each do |card, subsheet_probability|
          result[card] += probability * subsheet_probability
        end
      else
        result[element] += probability
      end
    end
    result
  end
end

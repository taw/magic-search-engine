class MixedPartnerCardSheet
  attr_reader :elements, :weights, :total_weight

  def initialize(elements, weights)
    @elements = elements
    raise "MixedPartnerCardSheet can only contain PartnerCardSheets" unless @elements.all?{|el| el.is_a?(PartnerCardSheet)}
    @weights = weights
    @total_weight = @weights.sum
  end

  def random_card
    raise "Partner sheet can only return 2 cards at time"
  end

  def random_cards_without_duplicates(count)
    raise "Partner sheet can only return 2 cards at time" unless count == 2
    random_number = rand(@total_weight)
    result = @weights.each_with_index do |w, i|
      random_number -= w
      break @elements[i] if random_number < 0
    end
    raise "Weighted sample algorithm failed" unless result
    result.random_cards_without_duplicates(count)
  end

  def cards
    elements.flat_map(&:cards).uniq
  end

  def probabilities
    result = Hash.new(Rational(0,1))
    @elements.each_with_index do |element, i|
      probability = Rational(@weights[i], @total_weight)
      element.probabilities.each do |card, subsheet_probability|
        result[card] += probability * subsheet_probability
      end
    end
    result
  end
end

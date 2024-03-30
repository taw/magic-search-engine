# elements are PhysicalCard elements
# at some point we might want to mix this and UST style card variants
# so we'd recursively allow CardSheets
class ColorBalancedCardSheet < CardSheet
  attr_reader :color_subsheets

  def initialize(elements, weights=nil)
    super
    wc = []
    ww = []
    uc = []
    uw = []
    bc = []
    bw = []
    rc = []
    rw = []
    gc = []
    gw = []
    cc = []
    cw = []

    prob = probabilities
    lcm = prob.values.map(&:denominator).inject(&:lcm)
    prob.each do |card, weight|
      # Don't count land cards for the color
      ci = card.color_identity
      ci = "" if card.main_front.types.include?("land")
      case ci
      when "w"
        wc << card
        ww << (weight * lcm).to_i
      when "u"
        uc << card
        uw << (weight * lcm).to_i
      when "b"
        bc << card
        bw << (weight * lcm).to_i
      when "r"
        rc << card
        rw << (weight * lcm).to_i
      when "g"
        gc << card
        gw << (weight * lcm).to_i
      else
        cc << card
        cw << (weight * lcm).to_i
      end
    end
    w = CardSheet.new(wc, ww)
    u = CardSheet.new(uc, uw)
    b = CardSheet.new(bc, bw)
    r = CardSheet.new(rc, rw)
    g = CardSheet.new(gc, gw)
    c = CardSheet.new(cc, cw)
    @color_subsheets = [w, u, b, r, g, c]
    @subsheet_weights = [ww, uw, bw, rw, gw, cw].map(&:sum)
    @subsheet_total_weight = @subsheet_weights.sum
    # Empty colorles is fine
    raise "#{set_code}/#{name} some colors don't have any cards, this sheet cannot be constructed" if [w, u, b, r, g].any?{|cs| cs.elements.empty?}
  end

  def random_cards_without_duplicates(count)
    if count <= 5
      raise "#{set_code}/#{name} can't color balance for size #{count}"
    end
    seen_names = Set[]
    result = []

    # Do guaranteed slots, so it never triggers duplicate issues
    @color_subsheets[0, 5].each do |subsheet, index|
      card = subsheet.random_card
      result << card
      seen_names << card.name
    end

    denominator, temp_weights = adjusted_weights_for(count)

    if temp_weights.any?{|ev| ev < 0}
      raise "#{set_code}/#{name} can't color balance for size #{count}"
    end

    # Mixed slots
    (count-5).times do
      # This can return nil if subsheet is tiny
      # but probability indicates we should return another card from it
      # Whenever this happens, a tiny bias is introduced
      card = random_card_with_adjusted_weights(temp_weights, denominator)
      redo if card.nil?
      card_name = card.name
      redo if seen_names.include?(card_name)
      result << card
      seen_names << card_name
    end

    result
  end

  private def random_card_with_adjusted_weights(weights, denominator)
    random_number = rand(denominator)
    weights.each_with_index do |w, i|
      random_number -= w
      return @color_subsheets[i].random_card if random_number <= 0
    end
    nil
  end

  def adjusted_weights_for(count)
    denominator = @subsheet_total_weight * (count-5)
    temp_weights = @subsheet_weights.each_with_index.map do |value, index|
      ev = value * count
      if index != 5
        ev - @subsheet_total_weight
      else
        ev
      end
    end
    [denominator, temp_weights]
  end

  # Just for error messages, so it doesn't have to be perfectly accurate
  # It could return something weird if card sheet has cards from multiple sets
  private def set_code
    @color_subsheets[0].elements[0].set_code
  end
end

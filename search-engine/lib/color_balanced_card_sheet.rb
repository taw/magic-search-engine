# elements are PhysicalCard elements
# at some point we might want to mix this and UST style card variants
# so we'd recursively allow CardSheets
class ColorBalancedCardSheet < CardSheet
  attr_reader :w, :u, :b, :r, :g, :c
  attr_reader :elements

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
    self.probabilities.each do |card, weight|
      # Don't count land cards for the color
      ci = card.color_identity
      ci = "" if card.main_front.types.include?("land")
      case ci
      when "w"
        wc << card
        ww << (weight * @total_weight).to_i
      when "u"
        uc << card
        uw << (weight * @total_weight).to_i
      when "b"
        bc << card
        bw << (weight * @total_weight).to_i
      when "r"
        rc << card
        rw << (weight * @total_weight).to_i
      when "g"
        gc << card
        gw << (weight * @total_weight).to_i
      else
        cc << card
        cw << (weight * @total_weight).to_i
      end
    end
    w = CardSheet.new(wc, ww)
    u = CardSheet.new(uc, uw)
    b = CardSheet.new(bc, bw)
    r = CardSheet.new(rc, rw)
    g = CardSheet.new(gc, gw)
    c = CardSheet.new(cc, cw)
    @elements = [w, u, b, r, g, c]
    @weights = @elements.map {|sheet| sheet.total_weight}
    @total_weight = @weights.sum
  end
  
  def random_card_custom_weight(weights, den)
    random_number = rand(den)
    result = weights.each_with_index do |w, i|
      random_number -= w
      break @elements[i].random_card if random_number <= 0
    end
    return result
  end
  
  def weights_for(count)
    denominator = @total_weight * (count-5)
    temp_weights = @weights.each_with_index.map do |value, index|
      ev = value * count
      if index != 5
        ev - @total_weight
      else
        ev
      end
    end
    return temp_weights.insert(0, denominator)
  end

  def random_cards_without_duplicates(count)
    if count <= 5
      raise "Set #{@elements[0].set_code} can't color balance size #{count}"
    end
    seen_names = Set[]
    # Reshuffle all subsheets

    result = Set[]
    # Do guaranteed slots, so it never triggers duplicate issues
    elements.each_with_index do |subsheet, index|
      if index != 5
        card = subsheet.random_card
        result << card
        seen_names << card.name
      end
    end
    
    temp_weights = weights_for(count)
    denominator = temp_weights.shift
    
    if temp_weights.any? {|ev| ev < 0}
      raise "Can't color balance #{count} for #{@elements[0].set_code}"
    end
    # Mixed slots
    (count-5).times do
      # This can return nil if subsheet is tiny
      # but probability indicates we should return another card from it
      # Whenever this happens, a tiny bias is introduced
      card = random_card_custom_weight(temp_weights, denominator)
      redo if card.nil?
      name = card.name
      redo if seen_names.include?(name)
      result << card
      seen_names << name
    end
    result.to_a
  end
end

# elements are PhysicalCard elements
# at some point we might want to mix this and UST style card variants
# so we'd recursively allow CardSheets
class ColorBalancedCardSheet < CardSheet
  attr_reader :w, :u, :b, :r, :g, :c
  attr_reader :elements

  def initialize(elements)
    unless elements.all?{|e| e.is_a?(PhysicalCard)}
      raise "Color balancing only works on cards for now"
    end
    super
    @w = []
    @u = []
    @b = []
    @r = []
    @g = []
    @c = []
    @elements.each do |card|
      # Don't count land cards for the color
      ci = card.color_identity
      ci = "" if card.main_front.types.include?("land")
      case ci
      when "w"
        @w << card
      when "u"
        @u << card
      when "b"
        @b << card
      when "r"
        @r << card
      when "g"
        @g << card
      else
        @c << card
      end
    end
  end

  def weights_for(count)
    n = @elements.size
    den = (count - 5) * n
    num_w = @w.size * count - n
    num_u = @u.size * count - n
    num_b = @b.size * count - n
    num_r = @r.size * count - n
    num_g = @g.size * count - n
    num_c = @c.size * count
    nums = [num_w, num_u, num_b, num_r, num_g, num_c]
    if nums.any?{|n| n < 0}
      nil
    else
      [den, num_w, num_u, num_b, num_r, num_g, num_c]
    end
  end

  def random_card_by_weights(den, nums, subsheets)
    i = rand(den)
    5.times do |j|
      i -= nums[j]
      return subsheets[j].shift if i < 0
    end
    subsheets.last.shift
  end

  def random_cards_without_duplicates(count)
    # Reshuffle all subsheets
    w = @w.shuffle
    u = @u.shuffle
    b = @b.shuffle
    r = @r.shuffle
    g = @g.shuffle
    c = @c.shuffle

    weights = weights_for(count)
    if weights.nil?
      raise "Can't color balance #{count} for #{@elements[0].set_code}"
    end
    return super if weights.nil?
    den, *nums = weights
    subsheets = [w, u, b, r, g, c]

    result = Set[]
    # Do guaranteed slots, so it never triggers duplicate issues
    [w, u, b, r, g].each do |subsheet|
      card = subsheet.shift
      result << card
    end
    # Mixed slots
    (count-5).times do
      # This can return nil if subsheet is tiny
      # but probability indicates we should return another card from it
      # Whenever this happens, a tiny bias is introduced
      card = random_card_by_weights(den, nums, subsheets)
      redo if card.nil?
      result << card
    end
    result.to_a
  end
end

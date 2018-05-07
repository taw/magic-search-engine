# CardSheet is collection of CardSheet and PhysicalCard elements
class CardSheet
  attr_reader :elements, :weights, :total_weight

  # Either Hash with weights
  # Or Array of equally equal elements
  def initialize(elements, weights=nil)
    @elements = elements
    @weights = weights
    if @weights
      @total_weight = @weights.inject(0, &:+)
    else
      @total_weight = @elements.size
    end
  end

  def cards
    @elements.flat_map do |element|
      if element.is_a?(CardSheet)
        element.cards
      else
        [element]
      end
    end
  end

  def number_of_cards
    @elements.map do |element|
      if element.is_a?(CardSheet)
        element.number_of_cards
      else
        1
      end
    end.inject(0, &:+)
  end

  def random_card
    if @weights
      random_number = rand(@total_weighw)
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
  def random_cards_without_duplicates(count)
    result = Set[]
    count.times do
      card = random_card
      redo if result.include?(random_card)
      result << card
    end
    result.to_a
  end

  class << self
    def rarity(set, rarity, foil: false)
      cards = set.physical_cards(foil).select(&:in_boosters?)
      # raise "#{set.code} #{set.same} has no cards in boosters" if cards.empty?
      cards = cards.select{|c| c.rarity == rarity}
      # raise "#{set.code} #{set.same} has no #{rarity} cards in boosters" if cards.empty?
      if cards.empty?
        nil
      else
        new(cards)
      end
    end

    # If rare or mythic sheet contains subsheets
    # treat variants as 1/N chance eachs
    # This only matters for Unstable
    def rare_or_mythic(set, foil: false)
      rare_sheet = rarity(set, "rare", foil: foil)
      mythic_sheet = rarity(set, "mythic", foil: foil)
      return rare_sheet unless mythic_sheet
      rare_weight = rare_sheet.elements.size
      mythic_weight = mythic_sheet.elements.size
      # Rares appear 2x more frequently on shared sheet
      new([rare_sheet, mythic_sheet], [2*rare_weight, mythic_weight])
    end

    def common_or_basic(set)
      common_sheet = rarity(set, "common")
      basic_sheet = rarity(set, "basic")
      return common_sheet unless basic_sheet
      common_weight = common_sheet.elements.size
      basic_weight = basic_sheet.elements.size
      # Assume basics are just commons for sheet purposes
      new([common_sheet, basic_sheet], [common_weight, basic_weight])
    end

    def masterpiece(set, range)
      new(set
        .printings
        .select{|c| range === c.number.to_i }
        .map{|c| PhysicalCard.for(c, true) })
    end

    def masterpieces_for(db, set_code)
      case set_code
      when "bfz"
        masterpiece(db.sets["exp"], 1..25)
      when "ogw"
        masterpiece(db.sets["exp"], 26..45)
      when "kld"
        masterpiece(db.sets["mps"], 1..30)
      when "aer"
        masterpiece(db.sets["mps"], 31..54)
      when "akh"
        masterpiece(db.sets["mps_akh"], 1..30)
      when "hou"
        masterpiece(db.sets["mps_akh"], 31..54)
      else
        nil
      end
    end
  end
end

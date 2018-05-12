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

  def probability(card=nil, &block)
    if card
      raise ArgumentError, "Pass card or block, not both" if block
      return probability{|c| c == card}
    end
    raise ArgumentError, "Pass card or block, not both" unless block
    num = 0
    den = 0
    @elements.each_with_index do |element, i|
      prob = @weights ? @weights[i] : 1
      num += prob * (if element.is_a?(CardSheet)
        element.probability(&block)
      else
        yield(element) ? 1 : 0
      end)
      den += prob
    end
    Rational(num, den)
  end

  class << self
    ### Additional Constructors
    def mix_sheets(*sheets)
      sheets = sheets.select{|s,w| s}
      return nil if sheets.size == 0
      return sheets[0][0] if sheets.size == 1
      new(sheets.map(&:first), sheets.map{|s,w| s.elements.size * w})
    end

    def from_query(db, query, assert_count=nil)
      cards = db.search("++ #{query}").printings.map{|c| PhysicalCard.for(c)}
      if assert_count and assert_count != cards.size
        raise "Expected query #{query} to return #{assert_count}, got #{cards.size}"
      end
      CardSheet.new(cards)
    end

    ### Usual Sheet Types

    # Wo don't have anywhere near reliable information
    # Masterpieces supposedly are in 1/144 booster (then 1/129 for Amonkhet), and they're presumably equally likely
    #
    # These numbers could be totally wrong. I base them on a million guesses by various internet commenters.
    def foil_sheet(set, masterpieces: nil)
      sheets = [rare_or_mythic(set, foil: true), rarity(set, "uncommon", foil: true)]
      weights = [4, 8]

      if masterpieces
        sheets << masterpieces
        weights << 1
      end

      basic_sheet = rarity(set, "basic", foil: true)
      if basic_sheet
        sheets << basic_sheet
        weights << 4
      end

      sheets << rarity(set, "common", foil: true)
      weights << (32 - weights.inject(0, &:+))

      CardSheet.new(sheets, weights)
    end

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
    # Rares appear 2x more frequently on shared sheet
    def rare_or_mythic(set, foil: false)
      mix_sheets(
        [rarity(set, "rare", foil: foil), 2],
        [rarity(set, "mythic", foil: foil), 1]
      )
    end

    def common_or_basic(set)
      # Assume basics are just commons for sheet purposes
      mix_sheets(
        [rarity(set, "common"), 1],
        [rarity(set, "basic"), 1],
      )
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

    ### Very old mixed rarity sheets

    # Antiquities U3 (uncommon) / U1 (rare) approximation
    def u3u1(set)
      mix_sheets(
        [rarity(set, "uncommon"), 3],
        [rarity(set, "rare"), 1],
      )
    end

    # Arabian Nights U3 (uncommon) / U2 (rare) approximation
    def u3u2(set)
      mix_sheets(
        [rarity(set, "uncommon"), 3],
        [rarity(set, "rare"), 2],
      )
    end

    # The Dark U2 (uncommon) / U1 (rare) approximation
    def u2u1(set)
      mix_sheets(
        [rarity(set, "uncommon"), 2],
        [rarity(set, "rare"), 1],
      )
    end

    ### These are really unique sheets

    def dgm_land_sheet(db)
      mix_sheets(
        [from_query(db, "is:shockland e:rtr,gtc", 10), 1], # 10 / 242
        [from_query(db, "e:dgm t:gate", 10), 23],          # 230 / 242
        [from_query(db, "e:dgm maze end", 1), 2],          # 2 / 242
      )
    end

    def ktk_fetchland_sheet(db)
      from_query(db, "e:ktk is:fetchland", 10)
    end

    def frf_gainlands(db)
      from_query(db, "e:frf is:gainland", 10)
    end

    def unhinged_foil_rares(db)
      from_query(db, "e:uh r>=rare", 44+1)
    end
  end
end

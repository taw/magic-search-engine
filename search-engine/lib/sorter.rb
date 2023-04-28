class Sorter
  COLOR_ORDER = ["", "w", "u", "b", "r", "g", "uw", "bu", "br", "gr", "gw", "bw", "ru", "bg", "rw", "gu", "guw", "buw", "bru", "bgr", "grw", "bgw", "ruw", "bgu", "brw", "gru", "bruw", "bgru", "bgrw", "gruw", "bguw", "bgruw"].each_with_index.to_h.freeze
  SORT_ORDERS = ["default", "ci", "cmc", "color", "name", "new", "newall", "number", "old", "oldall", "pow", "power", "rand", "random", "rarity", "tou", "toughness", "artist", "released", "set", "firstprint", "lastprint", "mv"].sort

  # Fallback sorting for printings of each card:
  # * not MTGO/Arena only
  # * new frame
  # * Standard only printing
  # * most recent
  # * set name
  # * card number as integer (10 > 2)
  # * card number as string (10A > 10)

  attr_reader :warnings, :sort_order

  def initialize(sort_order, seed)
    known_sort_orders = SORT_ORDERS + SORT_ORDERS.map{|s| "-#{s}"}

    @seed = seed
    @sort_order = sort_order ? sort_order.split(",") : []
    @warnings = []
    @sort_order = @sort_order.map do |part|
      if known_sort_orders.include?(part)
        part
      else
        @warnings << "Unknown sort order: #{part}. Known options are: #{SORT_ORDERS.join(", ")}; and their combinations."
        nil
      end
    end.compact
    @sort_order = nil if @sort_order.empty?
  end

  def sort(results)
    return results.sort_by(&:default_sort_index) unless @sort_order
    results.sort_by do |c|
      card_key(c)
    end
  end

  def ==(other)
    other.is_a?(Sorter) and sort_order == other.sort_order and warnings == other.warnings
  end

  private

  def card_key(c)
    @sort_order.flat_map do |part|
      case part
      when "default"
        [c.default_sort_index]
      when "-default"
        [-c.default_sort_index]
      when "new", "-old"
        [c.set.regular? ? 0 : 1, -c.release_date_i]
      when "old", "-new"
        [c.set.regular? ? 0 : 1, c.release_date_i]
      when "newall", "-oldall", "released"
        [-c.release_date_i]
      when "oldall", "-newall", "-released"
        [c.release_date_i]
      when "firstprint"
        [-c.first_release_date.to_i_sort]
      when "-firstprint"
        [c.first_release_date.to_i_sort]
      when "lastprint"
        [-c.last_release_date.to_i_sort]
      when "-lastprint"
        [c.last_release_date.to_i_sort]
      when "cmc", "mv"
        [c.cmc ? 0 : 1, -c.cmc.to_i]
      when "-cmc", "-mv"
        [c.cmc ? 0 : 1, c.cmc.to_i]
      when "pow", "power"
        [c.power ? 0 : 1, -c.power.to_i]
      when "-pow", "-power"
        [c.power ? 0 : 1, c.power.to_i]
      when "tou", "toughness"
        [c.toughness ? 0 : 1, -c.toughness.to_i]
      when "-tou", "-toughness"
        [c.toughness ? 0 : 1, c.toughness.to_i]
      when "rand", "-rand", "random", "-random"
        [Digest::MD5.hexdigest(@seed + c.name)]
      when "number"
        [c.set.name, c.number_i, c.number]
      when "-number"
        [reverse_string_order(c.set.name), -c.number_i, reverse_string_order(c.number)]
      when "set"
        [c.set_code, c.number_i, c.number]
      when "-set"
        [reverse_string_order(c.set_code), -c.number_i, reverse_string_order(c.number)]
      when "color"
        [COLOR_ORDER.fetch(c.colors)]
      when "-color"
        [-COLOR_ORDER.fetch(c.colors)]
      when "ci", "identity"
        [COLOR_ORDER.fetch(c.color_identity)]
      when "-ci", "-identity"
        [-COLOR_ORDER.fetch(c.color_identity)]
      when "rarity"
        [-c.rarity_code]
      when "-rarity"
        [c.rarity_code]
      when "name"
        [c.name]
      when "-name"
        [reverse_string_order(c.name)]
      when "artist"
        [c.artist_name.downcase]
      when "-artist"
        [reverse_string_order(c.artist_name.downcase)]
      else # unknown key, should have been caught by initializer
        raise "Invalid sort order #{part}"
      end
    end + [c.default_sort_index]
  end

  # This is a stupid hack, and also really slow
  def reverse_string_order(s)
    s.unpack("U*").map{|code| -code}
  end
end

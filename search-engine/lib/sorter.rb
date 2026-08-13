class Sorter
  COLOR_ORDER = ["", "w", "u", "b", "r", "g", "uw", "bu", "br", "gr", "gw", "bw", "ru", "bg", "rw", "gu", "guw", "buw", "bru", "bgr", "grw", "bgw", "ruw", "bgu", "brw", "gru", "bruw", "bgru", "bgrw", "gruw", "bguw", "bgruw"].each_with_index.to_h.freeze
  SORT_ORDERS = ["default", "ci", "cmc", "color", "name", "new", "newall", "number", "old", "oldall", "pow", "power", "rand", "random", "rarity", "tou", "toughness", "artist", "released", "set", "firstprint", "lastprint", "mv"].sort
  PT_ORDER = {
    nil => 0,
    "?" => 1,
    "*" => 2,
    "1+*" => 2,
    "2+*" => 3,
    "7-*" => 4,
    "*²" => 5,
    "∞" => 1000,
  }

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

  def map_pt(value)
    PT_ORDER[value] || 10 + (2 * value).to_i
  end

  def map_mv(value)
    return 1000 if value > 1000
    (value * 2).to_i
  end

  def card_key(c)
    @sort_order.flat_map do |part|
      case part
      when "default"
        [c.default_sort_index]
      when "-default"
        [-c.default_sort_index]
      when "new"
        [c.set.regular? ? 0 : 1, -c.release_date_i]
      when "old"
        [c.set.regular? ? 0 : 1, c.release_date_i]
      when "newall"
        [-c.release_date_i]
      when "oldall"
        [c.release_date_i]
      when "firstprint"
        [-c.first_release_date.to_i_sort]
      when "-firstprint"
        [c.first_release_date.to_i_sort]
      when "lastprint"
        [-c.last_release_date.to_i_sort]
      when "-lastprint"
        [c.last_release_date.to_i_sort]
      when "mv"
        [-map_mv(c.mv)]
      when "-mv"
        [map_mv(c.mv)]
      when "power"
        [-map_pt(c.power)]
      when "-power"
        [map_pt(c.power)]
      when "toughness"
        [-map_pt(c.toughness)]
      when "-toughness"
        [map_pt(c.toughness)]
      when "random"
        [Zlib.crc32(@seed + c.name)]
      when "number"
        [c.set.name_sort_index, c.number_sort_index]
      when "-number"
        [-c.set.name_sort_index, -c.number_sort_index]
      when "set"
        [c.set.name_sort_index]
      when "-set"
        [-c.set.name_sort_index]
      when "color"
        [COLOR_ORDER.fetch(c.colors)]
      when "-color"
        [-COLOR_ORDER.fetch(c.colors)]
      when "ci"
        [COLOR_ORDER.fetch(c.color_identity)]
      when "-ci"
        [-COLOR_ORDER.fetch(c.color_identity)]
      when "rarity"
        [-c.rarity_code]
      when "-rarity"
        [c.rarity_code]
      when "name"
        [c.name_sort_index]
      when "-name"
        [-c.name_sort_index]
      when "artist"
        [c.artist.sort_index]
      when "-artist"
        [-c.artist.sort_index]
      else # unknown key, should have been caught by initializer
        raise "Invalid sort order #{part}"
      end
    end + [c.default_sort_index]
  end
end

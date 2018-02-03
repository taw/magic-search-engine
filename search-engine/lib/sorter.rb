class Sorter
  COLOR_ORDER = ["w", "u", "b", "r", "g", "uw", "bu", "br", "gr", "gw", "bw", "ru", "bg", "rw", "gu", "buw", "bru", "bgr", "grw", "guw", "brw", "gru", "bgw", "ruw", "bgu", "bruw", "bgru", "bgrw", "gruw", "bguw", "bgruw", ""].each_with_index.to_h.freeze

  # Fallback sorting for printings of each card:
  # * not MTGO only
  # * new frame
  # * Standard only printing
  # * most recent
  # * set name
  # * card number as integer (10 > 2)
  # * card number as string (10A > 10)

  attr_reader :warnings, :sort_order

  def initialize(sort_order)
    known_sort_orders = ["ci", "cmc", "color", "name", "new", "newall", "number", "old", "oldall", "pow", "rand", "rarity", "tou"]
    known_sort_orders += known_sort_orders.map{|s| "-#{s}"}

    @sort_order = sort_order
    @warnings = []
    if @sort_order and not known_sort_orders.include?(@sort_order)
      @warnings << "Unknown sort order: #{@sort_order}"
      @sort_order = nil
    end
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
    case @sort_order
    when "new", "-old"
      [c.set.regular? ? 0 : 1, -c.release_date_i, c.default_sort_index]
    when "old", "-new"
      [c.set.regular? ? 0 : 1, c.release_date_i, c.default_sort_index]
    when "newall", "-oldall"
      [-c.release_date_i, c.default_sort_index]
    when "oldall", "-newall"
      [c.release_date_i, c.default_sort_index]
    when "cmc"
      [c.cmc ? 0 : 1, -c.cmc.to_i, c.default_sort_index]
    when "-cmc"
      [c.cmc ? 0 : 1, c.cmc.to_i, c.default_sort_index]
    when "pow"
      [c.power ? 0 : 1, -c.power.to_i, c.default_sort_index]
    when "-pow"
      [c.power ? 0 : 1, c.power.to_i, c.default_sort_index]
    when "tou"
      [c.toughness ? 0 : 1, -c.toughness.to_i, c.default_sort_index]
    when "-tou"
      [c.toughness ? 0 : 1, c.toughness.to_i, c.default_sort_index]
    when "rand", "-rand"
      [Digest::MD5.hexdigest(@query_string + c.name), c.default_sort_index]
    when "number"
      [c.set.name, c.number.to_i, c.number, c.default_sort_index]
    when "-number"
      [c.set.name, -c.number.to_i, reverse_string_order(c.number), c.default_sort_index]
    when "color"
      [COLOR_ORDER.fetch(c.colors), c.default_sort_index]
    when "-color"
      [COLOR_ORDER.fetch(c.colors), c.default_sort_index]
    when "ci"
      [COLOR_ORDER.fetch(c.color_identity), c.default_sort_index]
    when "-ci"
      [COLOR_ORDER.fetch(c.color_identity), c.default_sort_index]
    when "rarity"
      [-c.rarity_code, c.default_sort_index]
    when "-rarity"
      [c.rarity_code, c.default_sort_index]
    when "name"
      c.default_sort_index
    when "-name"
      [reverse_string_order(c.name), c.default_sort_index]
    else # unknown key, treat as name
      raise "Invalid sort order #{@sort_order}"
    end
  end

  # This is a stupid hack, and also really slow
  def reverse_string_order(s)
    s.unpack("U*").map{|code| -code}
  end
end

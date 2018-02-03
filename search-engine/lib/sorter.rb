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
    @sort_order = sort_order || "name"
    @warnings = []
    unless known_sort_orders.include?(@sort_order)
      @warnings << "Unknown sort order: #{@sort_order}"
    end
  end

  def sort(results)
    case @sort_order
    when "new"
      results.sort_by do |c|
        [c.set.regular? ? 0 : 1, -c.release_date_i, c.default_sort_index]
      end
    when "old"
      results.sort_by do |c|
        [c.set.regular? ? 0 : 1, c.release_date_i, c.default_sort_index]
      end
    when "newall"
      results.sort_by do |c|
        [-c.release_date_i, c.default_sort_index]
      end
    when "oldall"
      results.sort_by do |c|
        [c.release_date_i, c.default_sort_index]
      end
    when "cmc"
      results.sort_by do |c|
        [c.cmc ? 0 : 1, -c.cmc.to_i, c.default_sort_index]
      end
    when "pow"
      results.sort_by do |c|
        [c.power ? 0 : 1, -c.power.to_i, c.default_sort_index]
      end
    when "tou"
      results.sort_by do |c|
        [c.toughness ? 0 : 1, -c.toughness.to_i, c.default_sort_index]
      end
    when "rand"
      results.sort_by do |c|
        [Digest::MD5.hexdigest(@query_string + c.name), c.default_sort_index]
      end
    when "number"
      results.sort_by do |c|
        [c.set.name, c.number.to_i, c.number, c.default_sort_index]
      end
    when "color"
      results.sort_by do |c|
        [COLOR_ORDER.fetch(c.colors), c.default_sort_index]
      end
    when "ci"
      results.sort_by do |c|
        [COLOR_ORDER.fetch(c.color_identity), c.default_sort_index]
      end
    when "rarity"
      results.sort_by do |c|
        [-c.rarity_code, c.default_sort_index]
      end
    when "name"
      results.sort_by(&:default_sort_index)
    else # unknown key, treat as name
      results.sort_by(&:default_sort_index)
    end
  end

  def ==(other)
    other.is_a?(Sorter) and sort_order == other.sort_order and warnings == other.warnings
  end
end

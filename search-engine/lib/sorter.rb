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
  # Dates are days, so they're sized by their range, not by how many there are.
  # 16 bits reaches year 2149, and sort:new / sort:old need one bit on top for
  # the regular-set flag they sort by first.
  DATE_BITS = 16
  DATE_BIAS = (1 << DATE_BITS) - 1

  # How many bits we need to pack composite sort fields
  # We can be tight with fields that are fixed like color, or rarity
  # but we need to leave some space for growth for cards, names, sets, artists etc.
  OFFSET = {
    "random" => 32,
    "default" => 18,
    "number" => 18,
    "name" => 16,
    "new" => DATE_BITS + 1,
    "old" => DATE_BITS + 1,
    "newall" => DATE_BITS,
    "oldall" => DATE_BITS,
    "firstprint" => DATE_BITS,
    "lastprint" => DATE_BITS,
    "artist" => 12,
    "set" => 12,
    # map_pt / map_mv spread values out to 10 + 2 * value, with 1000 for ∞,
    # so these are sized by that range and not by how many values there are
    "power" => 10,
    "toughness" => 10,
    "mv" => 10,
    "color" => 5,
    "ci" => 5,
    "rarity" => 3,
  }.flat_map{|k,v| [[k,v], ["-#{k}",v]]}.to_h

  # Sort orders that count down rather than up. Subtracting from the field's
  # highest value reverses it while keeping it non-negative, so no key ever
  # needs a sign bit. sort:new and sort:old reverse only part of their field,
  # so they do it themselves in card_key.
  BIAS = [
    "-default",
    "-number",
    "-name",
    "-artist",
    "-set",
    "-color",
    "-ci",
    "rarity",
    "mv",
    "power",
    "toughness",
    "newall",
    "firstprint",
    "lastprint",
  ].to_h{|k| [k, (2**OFFSET[k])-1]}

  # These order every printing on their own, so any key after one of them is
  # unreachable. `random` is not one of them - it's the same number for every
  # printing of a card, so `sort:random,rarity` really does order the printings
  # of each card by rarity.
  FINAL_SORT_ORDERS = ["default", "-default", "number", "-number"]

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
    if @sort_order.empty?
      @sort_order = nil
    else
      # The key has to end in something that orders every printing, so that the
      # order is total. Adding it here rather than in card_key lets uniq and
      # FINAL_SORT_ORDERS drop it whenever the sort order already ends in one.
      @sort_order << "default"
      # Every key is a function of the printing, so repeating one changes nothing
      @sort_order = @sort_order.uniq
      if final = @sort_order.index{|part| FINAL_SORT_ORDERS.include?(part)}
        @sort_order = @sort_order[0..final]
      end
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

  def map_pt(value)
    PT_ORDER[value] || 10 + (2 * value).to_i
  end

  def map_mv(value)
    return 1000 if value > 1000
    (value * 2).to_i
  end

  # The sort key is one integer, with the first sort order in the high bits.
  # Building it back to front means each field only needs to know how far the
  # ones after it have already shifted.
  def card_key(c)
    result = 0
    offset = 0
    @sort_order.reverse_each do |part|
      value = BIAS[part] || 0
      case part
      when "default"
        value += c.default_sort_index
      when "-default"
        value -= c.default_sort_index
      when "new"
        value += ((c.set.regular? ? 0 : 1) << DATE_BITS) + DATE_BIAS - c.release_date_i
      when "old"
        value += ((c.set.regular? ? 0 : 1) << DATE_BITS) + c.release_date_i
      when "newall"
        value -= c.release_date_i
      when "oldall"
        value += c.release_date_i
      when "firstprint"
        value -= c.first_release_date.to_i_sort
      when "-firstprint"
        value += c.first_release_date.to_i_sort
      when "lastprint"
        value -= c.last_release_date.to_i_sort
      when "-lastprint"
        value += c.last_release_date.to_i_sort
      when "mv"
        value -= map_mv(c.mv)
      when "-mv"
        value += map_mv(c.mv)
      when "power"
        value -= map_pt(c.power)
      when "-power"
        value += map_pt(c.power)
      when "toughness"
        value -= map_pt(c.toughness)
      when "-toughness"
        value += map_pt(c.toughness)
      when "random"
        value += Zlib.crc32(@seed + c.name)
      when "number"
        value += c.set_number_sort_index
      when "-number"
        value -= c.set_number_sort_index
      when "set"
        value += c.set.name_sort_index
      when "-set"
        value -= c.set.name_sort_index
      when "color"
        value += COLOR_ORDER.fetch(c.colors)
      when "-color"
        value -= COLOR_ORDER.fetch(c.colors)
      when "ci"
        value += COLOR_ORDER.fetch(c.color_identity)
      when "-ci"
        value -= COLOR_ORDER.fetch(c.color_identity)
      when "rarity"
        value -= c.rarity_code
      when "-rarity"
        value += c.rarity_code
      when "name"
        value += c.name_sort_index
      when "-name"
        value -= c.name_sort_index
      when "artist"
        value += c.artist.sort_index
      when "-artist"
        value -= c.artist.sort_index
      else # unknown key, should have been caught by initializer
        raise "Invalid sort order #{part}"
      end
      result += value << offset
      offset += OFFSET.fetch(part)
    end
    result
  end

  # This method is kept for equivalence spec only
  def old_card_key(c)
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
    end
  end
end

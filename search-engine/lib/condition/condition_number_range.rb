class ConditionNumberRange < ConditionSimple
  def initialize(ranges)
    @ranges = ranges.downcase.split(",").map{|range|
      a, b = range.split("-", 2)
      b ||= a
      [[a.to_i, a], [b.to_i, b =~ /\D/ ? b : "#{b}zzz"], a == "set", b == "set"]
    }
  end

  def match?(card)
    card_number_s = card.number.downcase
    card_number_i = card.number_i
    key = [card_number_i, card_number_s]
    @ranges.any? do |a, b, aset, bset|
      if aset
        base_set_size = card.set.base_set_size
        next unless base_set_size && (card_number_i >= base_set_size)
      else
        next unless (key <=> a) >= 0
      end

      if bset
        base_set_size = card.set.base_set_size
        base_set_size && (card_number_i <= card.set.base_set_size)
      else
        (key <=> b) <= 0
      end
    end
  end

  def to_s
    "number:#{@ranges.map{|(ai, as), (bi, bs)|
      if as == bs
        as
      else
        "#{as}-#{bs}"
      end
    }.join(",")}"
  end
end

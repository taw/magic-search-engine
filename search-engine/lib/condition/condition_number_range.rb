class ConditionNumberRange < ConditionSimple
  def initialize(ranges)
    if ranges =~ /\A(\d+)-(\d+)\z/
      @range = ($1.to_i..$2.to_i)
    else
      @ranges = ranges.downcase.split(",").map{|range|
        a, b = range.split("-", 2)
        b ||= a
        # bs is padded with a sentinel so that string comparison of numerically
        # equal numbers puts "5b" inside 1-5; bo keeps the original text for to_s
        [a.to_i, a, b.to_i, b =~ /\D/ ? b : "#{b}zzz", a == "set", b == "set", b]
      }
    end
  end

  def match?(card)
    card_number_i = card.number_i

    if @range
      return @range.cover?(card_number_i)
    end

    @ranges.each do |ai, as, bi, bs, aset, bset|
      if aset
        base_set_size = card.set.base_set_size
        next unless base_set_size && (card_number_i >= base_set_size)
      else
        next unless card_number_i >= ai
        if card_number_i == ai
          next unless card.number.downcase >= as
        end
      end

      if bset
        base_set_size = card.set.base_set_size
        next unless base_set_size && (card_number_i <= base_set_size)
      else
        next unless card_number_i <= bi
        if card_number_i == bi
          next unless card.number.downcase <= bs
        end
      end

      return true
    end

    false
  end

  def to_s
    if @range
      "number:#{@range.begin}-#{@range.end}"
    else
      "number:#{@ranges.map{|ai, as, bi, bs, aset, bset, bo|
        if as == bo
          as
        else
          "#{as}-#{bo}"
        end
      }.join(",")}"
    end
  end
end

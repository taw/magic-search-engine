class ConditionNumberRange < ConditionSimple
  def initialize(ranges)
    @ranges = ranges.downcase.split(",").map{|range|
      a, b = range.split("-", 2)
      b ||= a
      [[a.to_i, a.to_s], [b.to_i, b.to_s]]
    }
  end

  def match?(card)
    card_number_s = card.number.downcase
    card_number_i = card.number.to_i
    key = [card_number_i, card_number_s]
    @ranges.any? do |a, b|
      if a[1] == "set"
        if card.set.base_set_size
          acond = (card_number_i >= card.set.base_set_size)
        else
          acord = false
        end
      else
        acond = (key <=> a) >= 0
      end
      if b[1] == "set"
        if card.set.base_set_size
          bcond = (card_number_i <= card.set.base_set_size)
        else
          bcond = false
        end
      else
        bcond = (key <=> b) <= 0
      end
      acond && bcond
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

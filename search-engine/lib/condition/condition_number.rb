class ConditionNumber < ConditionSimple
  def initialize(number, op=":")
    @number_s = number.downcase
    @number_i = @number_s.to_i
    @op = op
  end

  def match?(card)
    if @number_s == "set"
      left = card.number_i
      right = card.set.base_set_size
    else
      card_number_s = card.number.downcase
      card_number_i = card.number_i
      left = [card_number_i, card_number_s]
      right = [@number_i, @number_s]
    end

    case @op
    when ">"
      (left <=> right) > 0
    when ">="
      (left <=> right) >= 0
    when "<"
      (left <=> right) < 0
    when "<="
      (left <=> right) <= 0
    else # = or :
      left == right
    end
  end

  def to_s
    "number#{@op}#{maybe_quote(@number_s)}"
  end
end

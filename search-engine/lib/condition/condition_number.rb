class ConditionNumber < ConditionSimple
  def initialize(number, op=":")
    @number_s = number.downcase
    @number_i = @number_s.to_i
    @op = op
  end

  def match?(card)
    card_number_s = card.number.downcase
    card_number_i = card.number.to_i
    case @op
    when ">"
      ([card_number_i, card_number_s] <=> [@number_i, @number_s]) > 0
    when ">="
      ([card_number_i, card_number_s] <=> [@number_i, @number_s]) >= 0
    when "<"
      ([card_number_i, card_number_s] <=> [@number_i, @number_s]) < 0
    when "<="
      ([card_number_i, card_number_s] <=> [@number_i, @number_s]) <= 0
    else # = or :
      card_number_s == @number_s
    end
  end

  def to_s
    "number#{@op}#{maybe_quote(@number_s)}"
  end
end

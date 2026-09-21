class ConditionNumber < ConditionSimple
  def initialize(number, op=":")
    @number_s = number.downcase
    @number_i = @number_s.to_i
    @op = op
  end

  def match?(card)
    if @number_s == "set"
      cmp = card.number_i <=> card.set.base_set_size
    else
      cmp = card.number_i <=> @number_i
      cmp = card.number.downcase <=> @number_s if cmp == 0
    end

    case @op
    when ">"
      cmp > 0
    when ">="
      cmp >= 0
    when "<"
      cmp < 0
    when "<="
      cmp <= 0
    else # = or :
      cmp == 0
    end
  end

  def to_s
    "number#{@op}#{maybe_quote(@number_s)}"
  end

  OP_WORDS = {">" => "is greater than", ">=" => "is at least", "<=" => "is at most", "<" => "is less than"}

  def explain
    value = @number_s == "set" ? "the set's base size" : @number_s
    "the collector number #{OP_WORDS.fetch(@op, "is")} #{value}"
  end
end

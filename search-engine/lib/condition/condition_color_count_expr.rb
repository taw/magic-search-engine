class ConditionColorCountExpr < ConditionSimple
  def initialize(a, op, b)
    @a = a.downcase
    @op = op
    @b = b.to_i
  end

  def match?(card)
    if @a == "c"
      a = card.colors.size
    else
      a = card.color_identity.size
    end

    case @op
    when "="
      a == @b
    when ">="
      a >= @b
    when ">"
      a > @b
    when "<="
      a <= @b
    when "<"
      a < @b
    else
      raise "Expr comparison parse error: #{@op}"
    end
  end

  def to_s
    "#{@a}#{@op}#{@b}"
  end
end

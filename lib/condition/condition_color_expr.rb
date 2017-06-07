class ConditionColorExpr < ConditionSimple
  def initialize(a, op, b)
    @a = a.downcase
    @op = op
    @b = (b.downcase.chars & %W[w u b r g]).to_set
  end

  def match?(card)
    if @a == "c"
      a = card.colors.chars.to_set
    else
      a = card.color_identity.chars.to_set
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

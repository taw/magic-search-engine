class ConditionExpr < ConditionSimple
  def initialize(a, op, b)
    @a = a
    @op = op
    @b = b
  end

  def match?(card)
    a = eval_expr(card, @a)
    b = eval_expr(card, @b)
    return false unless a and b
    return false if a.is_a?(String) != b.is_a?(String)
    case @op
    when "="
      a == b
    when ">="
      a >= b
    when ">"
      a > b
    when "<="
      a <= b
    when "<"
      a < b
    else
      raise "Expr comparison parse error: #{@op}"
    end
  end

  def to_s
    "#{@a}#{@op}#{@b}"
  end

  private

  def eval_expr(card, expr)
    case expr
    when "pow"
      card.power
    when "tou"
      card.toughness
    when "cmc"
      card.cmc
    when "loyalty"
      card.loyalty
    when "year"
      card.year
    when /\A-?\d+\z/
      expr.to_i
    when /\A-?\d*\.\d+\z/
      expr.to_f
    when /\A(-?\d*)½\z/
      # Negative half numbers never happen or real cards, but for sake of completeness
      if expr[0] == "-"
        $1.to_i - 0.5
      else
        $1.to_i + 0.5
      end
    else
      raise "Expr variable parse error: #{expr}"
    end
  end
end

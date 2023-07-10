class ConditionExpr < ConditionSimple
  def initialize(a, op, b)
    @a = a
    @op = op
    @b = b
  end

  def match?(card)
    ac, av = eval_expr(card, @a)
    bc, bv = eval_expr(card, @b)
    # p [:comparing, [@a, @op, @b], card.name, [ac, av], [bc, bv]]
    return false unless ac and bc and ac == bc

    case @op
    when "="
      av == bv
    when ">="
      av >= bv
    when ">"
      av > bv
    when "<="
      av <= bv
    when "<"
      av < bv
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
      eval_card_value(card.power)
    when "tou"
      eval_card_value(card.toughness)
    when "cmc", "mv"
      eval_card_value(card.cmc)
    when "loy"
      eval_card_value(card.loyalty)
    when "sets"
      eval_card_value(card.count_sets)
    when "papersets"
      eval_card_value(card.count_papersets)
    when "prints"
      eval_card_value(card.count_prints)
    when "paperprints"
      eval_card_value(card.count_paperprints)
    when "year"
      [:number, card.year]
    when "defense", "defence"
      eval_card_value(card.defense)
    when "life"
      eval_card_value(card.life)
    when "hand"
      eval_card_value(card.hand)
    when "decklimit"
      eval_card_value(card.decklimit || 4)
    else
      eval_card_value(expr)
    end
  end

  def eval_card_value(expr)
    return [nil, nil] unless expr
    return [:number, expr] unless expr.is_a?(String)
    case expr
    when /\A[\-\+]?\d+\z/
      [:number, expr.to_i]
    when /\A[\-\+]?\d*\.\d+\z/
      [:number, expr.to_f]
    when /\A(-?\d*)½\z/
      # Negative half numbers never happen or real cards, but for sake of completeness
      if expr[0] == "-"
        [:number, $1.to_i - 0.5]
      else
        [:number, $1.to_i + 0.5]
      end
    when "*"
      [:star, 0]
    when /\A\*([\+\-]\d+)\z/, /\A(\d+)\+\*\z/
      [:star, $1.to_i]
    when /\A(\d+)\-\*\z/
      [:negstar, $1.to_i]
    when /\A\*[2²]\z/
      [:starsq, 0]
    when /\Ax\z/i
      [:x, 0]
    when /\A\?\z/i
      [:question_mark, 0]
    when /\A∞\z/, "any"
      [:number, Float::INFINITY]
    when "1d4+1"
      [:"1d4", 1]
    else
      warn "Expr variable parse error: #{expr.inspect}"
      [nil, nil]
    end
  end
end

class ConditionExpr < ConditionSimple
  # Everything eval_expr knows how to look up on a card, anything else is a plain value
  Variables = %W[pow tou pt mv loy sets papersets prints paperprints year defense defence life hand decklimit]

  # mv:even and friends ask about the value's parity, not its magnitude,
  # so the right hand side isn't a value to compare with at all
  Parities = %W[even odd]

  def initialize(a, op, b)
    @a = a
    @op = op
    @b = b
    # Operands which aren't card variables are constants like "4" or "*",
    # so parse them once here instead of once per card in #match?
    # The ones which are get turned into symbols, as eval_expr dispatches on them a lot.
    Variables.include?(@a) ? @a_var = @a.to_sym : @a_value = eval_card_value(@a)
    if Parities.include?(@b)
      @parity = @b.to_sym
    else
      Variables.include?(@b) ? @b_var = @b.to_sym : @b_value = eval_card_value(@b)
    end
  end

  # warning needs @logger, which we only get here, not in initialize
  def metadata!(key, value)
    super
    return unless key == :logger
    if @parity and @op != "="
      warning %[Only = is supported for #{@b} queries, ignoring #{@op} in "#{self}"]
    end
    [@a, @b].each do |expr|
      next if Variables.include?(expr) or Parities.include?(expr)
      next unless eval_card_value(expr) == [nil, nil]
      warning %[Unknown value "#{expr}" in "#{self}"]
    end
  end

  def match?(card)
    ac, av = @a_value || eval_expr(card, @a_var)
    # Only whole numbers have a parity - not */X/?, not Little Girl's half mana value,
    # and not the infinity that "any" stands for
    return ac == :number && av.is_a?(Integer) && av.send(:"#{@parity}?") if @parity
    bc, bv = @b_value || eval_expr(card, @b_var)
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

  # "pt" is printed as "powtou", as pt=* would otherwise come back as a Portuguese name search
  def to_s
    "#{unambiguous(@a)}#{@op}#{unambiguous(@b)}"
  end

  private

  def unambiguous(expr)
    expr == "pt" ? "powtou" : expr
  end

  # expr is always one of Variables, as symbol
  def eval_expr(card, expr)
    case expr
    when :pow
      eval_card_value(card.power)
    when :tou
      eval_card_value(card.toughness)
    when :pt
      eval_sum(eval_card_value(card.power), eval_card_value(card.toughness))
    when :mv
      eval_card_value(card.mv)
    when :loy
      eval_card_value(card.loyalty)
    when :sets
      eval_card_value(card.count_sets)
    when :papersets
      eval_card_value(card.count_papersets)
    when :prints
      eval_card_value(card.count_prints)
    when :paperprints
      eval_card_value(card.count_paperprints)
    when :year
      [:number, card.year]
    when :defense, :defence
      eval_card_value(card.defense)
    when :life
      eval_card_value(card.life)
    when :hand
      eval_card_value(card.hand)
    when :decklimit
      eval_card_value(card.decklimit || 4)
    else
      raise "Unknown card variable #{expr}"
    end
  end

  # Adding a number to a star keeps the star, so Tarmogoyf's */1+* adds up to 1+*,
  # and anything weirder than that (X, ?, *², 1d4+1) has no sensible total
  def eval_sum(a, b)
    ac, av = a
    bc, bv = b
    if ac == bc and (ac == :number or ac == :star)
      [ac, av + bv]
    elsif (ac == :number and bc == :star) or (ac == :star and bc == :number)
      [:star, av + bv]
    else
      [nil, nil]
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
      # Nothing sensible to compare with, the warning comes from metadata!
      [nil, nil]
    end
  end
end

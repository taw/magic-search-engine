class ConditionTypeExpr < ConditionSimple
  def initialize(op, types)
    @op = op
    # * cleanup unicode
    # * Urza's -> Urza
    # * Some planes have multiword names, turn them into dashes
    types = types
      .downcase
      .tr("’\u2212", "'-")
      .gsub(/'s/, "")
      .gsub(/\s+/, " ")
      .gsub("new phyrexia", "new-phyrexia")
      .gsub("serra realm", "serra-realm")
      .gsub("bolas meditation realm", "bolas-meditation-realm")
      .gsub("tribal", "kindred")
    @types = types.split.to_set
  end

  def match?(card)
    card_types = card.types.to_set
    case @op
    when "="
      card_types == @types
    when ">="
      card_types >= @types
    when ">"
      card_types > @types
    when "<="
      card_types <= @types
    when "<"
      card_types < @types
    else
      raise "Expr comparison parse error: #{@op}"
    end
  end

  def to_s
    "t#{@op}#{maybe_quote(@types.to_a.join(' '))}"
  end

  OP_WORDS = {"=" => "are exactly", ">=" => "include", ">" => "include", "<=" => "are a subset of", "<" => "are a strict subset of"}
  # Types are a set, not a total order, so "not (types >= X)" is NOT "types < X"
  # (that's just one of several ways to fail to be a superset) - it has to stay a
  # plain negation of set inclusion, not flip to a different comparison operator.
  NEGATED_OP_WORDS = {"=" => "aren't exactly", ">=" => "don't include", ">" => "don't include", "<=" => "aren't limited to", "<" => "aren't strictly within"}

  def explain(negated: false)
    words = negated ? NEGATED_OP_WORDS : OP_WORDS
    suffix = (!negated && @op == ">") ? ", plus at least one more" : ""
    "the card types #{words.fetch(@op, @op)} #{@types.to_a.join(' and ')}#{suffix}"
  end
end

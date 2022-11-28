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
      raise "Expr comparison parse error: #{op}"
    end
  end

  def to_s
    "t#{@op}#{maybe_quote(@types.join(' '))}"
  end
end

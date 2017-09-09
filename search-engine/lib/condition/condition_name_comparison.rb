class ConditionNameComparison < ConditionSimple
  def initialize(op, name)
    @op = op
    @name = normalize_for_comparison(name)
  end

  def match?(card)
    card_name = normalize_for_comparison(card.name)
    case @op
    when "="
      card_name == @name
    when ">"
      card_name > @name
    when ">="
      card_name >= @name
    when "<="
      card_name <= @name
    when "<"
      card_name < @name
    else
      raise "Unrecognized comparison #{@op}"
    end
  end

  def to_s
    "name#{@op}#{maybe_quote(@name)}"
  end

  private

  def normalize_for_comparison(name)
    name.downcase.gsub(/[,']/, "")
  end
end

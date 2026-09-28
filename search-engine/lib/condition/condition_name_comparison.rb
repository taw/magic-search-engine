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

  OP_WORDS = {"=" => "is exactly", ">" => "is alphabetically after", ">=" => "is alphabetically at or after", "<=" => "is alphabetically at or before", "<" => "is alphabetically before"}
  # Names are totally ordered, so negating a comparison flips it to its opposite.
  NEGATED_OP_WORDS = {"=" => "isn't exactly", ">" => "is alphabetically at or before", ">=" => "is alphabetically before", "<=" => "is alphabetically after", "<" => "is alphabetically at or after"}

  def explain(negated: false)
    "the name #{(negated ? NEGATED_OP_WORDS : OP_WORDS).fetch(@op)} \"#{@name}\""
  end

  private

  def normalize_for_comparison(name)
    name.downcase.gsub(/[,']/, "")
  end
end

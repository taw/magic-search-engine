class ConditionExactMultipart < ConditionSimple
  def initialize(name)
    @name = name
    @name_parts = @name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
  end

  def match?(card)
    card.names and (@name_parts - card.names.map(&:downcase)).empty?
  end

  def to_s
    "!#{@name}"
  end

  def explain(negated: false)
    parts = @name.split(%r[(?:&|/)+]).map{|n| "\"#{n.strip}\""}.join(" and ")
    "the card #{negated ? "doesn't have" : "has"} parts named exactly #{parts}"
  end
end

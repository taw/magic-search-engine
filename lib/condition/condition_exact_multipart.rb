class ConditionExactMultipart < ConditionSimple
  def initialize(name)
    @name = name
    @name_parts = @name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
  end

  def include_extras?
    true
  end

  def match?(card)
    card.names and (@name_parts - card.names.map(&:downcase)).empty?
  end

  def to_s
    "!#{@name}"
  end
end

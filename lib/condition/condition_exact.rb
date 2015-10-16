class ConditionExact < Condition
  def initialize(name)
    @name = name
  end

  def match?(card)
    query_name = @name
    if query_name =~ %r[&|/]
      return false unless card.names
      query_parts = query_name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
      card_parts  = card.names.map{|n| normalize_name(n)}
      (query_parts - card_parts).empty?
    else
      normalize_name(card.name) == normalize_name(query_name)
    end
  end

  def include_extras?
    true
  end

  def to_s
    "!#{@name}"
  end
end

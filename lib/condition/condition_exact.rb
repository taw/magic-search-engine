class ConditionExact < ConditionSimple
  def initialize(name)
    @name = name
    if @name =~ %r[&|/]
      @name_parts = @name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    else
      @normalized_name = normalize_name(@name)
    end
  end

  def match?(card)
    if @name_parts
      card.names and (@name_parts - card.names.map(&:downcase)).empty?
    else
      card.name.downcase == @normalized_name
    end
  end

  def include_extras?
    true
  end

  def to_s
    "!#{@name}"
  end
end

class ConditionExact < Condition
  def initialize(name)
    @name = name
    if @name =~ %r[&|/]
      @name_parts = @name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
    else
      @normalized_name = normalize_name(@name)
    end
  end

  def include_extras?
    true
  end

  def search(db)
    if @name_parts
      db.cards.values.select do |card|
        card.names and (@name_parts - card.names.map(&:downcase)).empty?
      end.flat_map(&:printings).to_set
    else
      db.cards.keys.select do |name|
        name.downcase == @normalized_name
      end.flat_map{|name| db.cards[name].printings}.to_set
    end
  end

  def to_s
    "!#{@name}"
  end
end

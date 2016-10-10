class ConditionExact < Condition
  def initialize(name)
    @name = name
    @normalized_name = normalize_name(@name)
  end

  def include_extras?
    true
  end

  def search(db)
    db.cards.keys.select do |name|
      name.downcase == @normalized_name
    end.flat_map{|name| db.cards[name].printings}.to_set
  end

  def to_s
    "!#{@name}"
  end
end

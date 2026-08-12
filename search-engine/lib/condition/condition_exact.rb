class ConditionExact < Condition
  def initialize(name)
    @name = name
    @normalized_name = normalize_name(@name)
  end

  def search_all(db)
    card = db.cards[@normalized_name]
    card ? card.printings : []
  end

  def to_s
    "!#{@name}"
  end
end

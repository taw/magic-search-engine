class ConditionExact < Condition
  def initialize(name)
    @name = name
    @normalized_name = normalize_name(@name)
  end

  def include_extras?
    true
  end

  def search(db)
    card = db.cards[@normalized_name]
    if card
      card.printings.to_set
    else
      Set[]
    end
  end

  def to_s
    "!#{@name}"
  end
end

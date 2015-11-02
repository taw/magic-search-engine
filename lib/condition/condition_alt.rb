class ConditionAlt < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    cards = Set[]
    @cond.search(db).each do |card_printing|
      cards << card_printing.card
    end
    results = Set[]
    cards.each do |card|
      card.printings.each do |printing|
        results << printing
      end
    end
    results
  end

  def metadata=(options)
    super
    @cond.metadata = options
  end

  def to_s
    "alt:#{@cond}"
  end
end

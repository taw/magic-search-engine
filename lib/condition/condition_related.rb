class ConditionRelated < Condition
  def initialize(cond)
    @cond = cond
  end

  def search(db)
    results = Set[]
    @cond.search(db).each do |card|
      next unless card.related
      card.related.each do |related_name|
        related_card = db.cards[related_name.downcase]
        next unless related_card # Not supposed to happen, but related is just a regexp
        related_card.printings.each do |printing|
          results << printing
        end
      end
    end
    results
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "related:#{@cond}"
  end
end

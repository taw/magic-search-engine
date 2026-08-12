class ConditionRelated < Condition
  def initialize(cond)
    @cond = cond
  end

  def search_all(db)
    results = []
    @cond.search(db).each do |card|
      next unless card.related
      card.related.each do |related_name|
        related_card = db.cards[related_name.downcase.normalize_accents]
        next unless related_card # Not supposed to happen, but related is just a regexp
        results.concat(related_card.printings)
      end
    end
    results.uniq
  end

  def metadata!(key, value)
    super
    @cond.metadata!(key, value)
  end

  def to_s
    "related:#{@cond}"
  end
end

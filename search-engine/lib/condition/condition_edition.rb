class ConditionEdition < Condition
  def initialize(*editions)
    @editions = editions.map{|e| normalize_name(e)}
  end

  def search(db)
    cards = merge_into_set( @editions.map{|e| db.resolve_editions(e)} )
    merge_into_set cards.map(&:printings)
  end

  def to_s
    "e:#{@editions.map{|e| maybe_quote(e)}.join(",")}"
  end
end

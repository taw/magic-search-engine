class ConditionEdition < Condition
  def initialize(*editions)
    @editions = editions.map{|e| normalize_name(e)}
  end

  def search(db)
    matching_sets = merge_into_set( @editions.map{|e| db.resolve_editions(e)} )
    merge_into_set matching_sets.map(&:printings)
  end

  def to_s
    "e:#{@editions.map{|e| maybe_quote(e)}.join(",")}"
  end
end

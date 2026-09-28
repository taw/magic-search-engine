class ConditionEdition < Condition
  def initialize(*editions)
    @editions = editions.map{|e| normalize_name(e)}
  end

  def search_all(db)
    matching_sets = merge_results( @editions.map{|e| db.resolve_editions(e)} )
    merge_disjoint_results matching_sets.map(&:printings)
  end

  def to_s
    "e:#{@editions.map{|e| maybe_quote(e)}.join(",")}"
  end

  def explain(negated: false)
    names = @editions.map{|e| %["#{e}"]}
    return "the set is #{names.join(" or ")}" unless negated
    names.size == 1 ? "the set is not #{names[0]}" : "the set is not any of #{names.join(", ")}"
  end
end

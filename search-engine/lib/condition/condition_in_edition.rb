class ConditionInEdition < Condition
  def initialize(*editions)
    @editions = editions.map{|e| normalize_name(e)}
  end

  def search_all(db)
    matching_sets = merge_results( @editions.map{|e| db.resolve_editions(e)} )
    printings_in_selected_sets = merge_disjoint_results matching_sets.map(&:printings)
    matching_cards = printings_in_selected_sets.map(&:card).uniq
    merge_disjoint_results matching_cards.map(&:printings)
  end

  def to_s
    "in:#{@editions.map{|e| maybe_quote(e)}.join(",")}"
  end
end

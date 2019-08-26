class ConditionInEdition < Condition
  def initialize(*editions)
    @editions = editions.map{|e| normalize_name(e)}
  end

  def search(db)
    matching_sets = merge_into_set( @editions.map{|e| db.resolve_editions(e)} )
    printings_in_selected_sets = merge_into_set matching_sets.map(&:printings)
    matching_cards = printings_in_selected_sets.map(&:card).to_set
    merge_into_set matching_cards.map(&:printings)
  end

  def to_s
    "in:#{@editions.map{|e| maybe_quote(e)}.join(",")}"
  end
end

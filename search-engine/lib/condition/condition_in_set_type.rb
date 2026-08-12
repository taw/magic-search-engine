class ConditionInSetType < ConditionSetType
  def search_all(db)
    printings_in_selected_sets = merge_disjoint_results matching_sets(db).map(&:printings)
    matching_cards = printings_in_selected_sets.map(&:card).uniq
    merge_disjoint_results matching_cards.map(&:printings)
  end

  def to_s
    "in:#{maybe_quote(@set_type)}"
  end
end

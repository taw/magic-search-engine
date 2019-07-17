class ConditionInSetType < ConditionSetType
  def search(db)
    printings_in_selected_sets = merge_into_set matching_sets(db).map(&:printings)
    matching_cards = printings_in_selected_sets.map(&:card).to_set
    merge_into_set matching_cards.map(&:printings)
  end

  def to_s
    "in:#{maybe_quote(@set_type)}"
  end
end

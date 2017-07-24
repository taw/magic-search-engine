class ConditionIsDigital < Condition
  def search(db)
    merge_into_set db.sets.values.select(&:online_only?).map(&:printings)
  end

  def to_s
    "is:digital"
  end
end

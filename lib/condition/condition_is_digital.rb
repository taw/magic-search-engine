class ConditionIsDigital < Condition
  def search(db)
    db.sets.values.select(&:online_only?).map(&:printings).inject(Set[], &:|)
  end

  def to_s
    "is:digital"
  end
end

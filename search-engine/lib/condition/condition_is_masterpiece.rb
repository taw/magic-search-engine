class ConditionIsMasterpiece < Condition
  def search(db)
    merge_into_set matching_sets(db).map(&:printings)
  end

  def to_s
    "is:masterpiece"
  end

  private

  def matching_sets(db)
    db.sets.values.select do |set|
      set.types.include?("masterpiece")
    end
  end
end

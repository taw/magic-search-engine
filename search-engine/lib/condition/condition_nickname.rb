class ConditionNickname < Condition
  def names
    raise "SubclassResponsibility"
  end

  def search_all(db)
    names
      .map{|n| db.cards[n]}
      .compact
      .uniq
      .flat_map(&:printings)
  end
end

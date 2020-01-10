class ConditionNickname < Condition
  def names
    raise "SubclassResponsibility"
  end

  def search(db)
    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end
end

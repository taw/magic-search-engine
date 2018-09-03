class ConditionIsKeywordsoup < Condition
  def search(db)
    # A card goes on this list if it lists a large number of keywords in a single sentence, and the keywords aren't ordered canonically.
    # A good indicator of this is that haste is listed before trample.
    names = [
      "animus of predation",
      "cairn wanderer",
      "concerted effort",
      "death-mask duplicant",
      "greater morphling",
      "majestic myriarch",
      "odric, lunarch marshal",
      "soulflayer",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:keywordsoup"
  end
end

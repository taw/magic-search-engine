class ConditionIsManland < Condition
  def search(db)
    names = [
      "blinkmoth nexus",
      "celestial colonnade",
      "creeping tar pit",
      "domesticated watercourse",
      "dread statuary",
      "faerie conclave",
      "forbidding watchtower",
      "frostwalk bastion",
      "ghitu encampment",
      "hissing quagmire",
      "hostile desert",
      "inkmoth nexus",
      "lavaclaw reaches",
      "lumbering falls",
      "mishra's factory",
      "mobilized district",
      "mutavault",
      "nantuko monastery",
      "needle spires",
      "raging ravine",
      "shambling vent",
      "sorrow's path",
      "spawning pool",
      "stalking stones",
      "stirring wildwood",
      "svogthos, the restless tomb",
      "treetop village",
      "wandering fumarole",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:manland"
  end
end

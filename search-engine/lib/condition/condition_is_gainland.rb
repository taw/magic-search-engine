class ConditionIsGainland < ConditionNickname
  def names
    [
      "a.i.m. labs",
      "akoum refuge",
      "andoria",
      "asgardian citadel",
      "avengers hangar",
      "bajor",
      "birnin zana plaza",
      "bloodfell caves",
      "blossoming sands",
      "cardassia prime",
      "dimension x",
      "dismal backwater",
      "earth, sector 001",
      "ferenginar",
      "fisk tower",
      "foot headquarters",
      "graypelt refuge",
      "hell's kitchen",
      "illegitimate business",
      "jungle hollow",
      "jwar isle refuge",
      "kazandu refuge",
      "los diablos missile base",
      "mutant town",
      "orion",
      "pym technologies",
      "qo'nos",
      "risa",
      "romulus",
      "rugged highlands",
      "scoured barrens",
      "sejiri refuge",
      "stark industries",
      "subterranean cavern",
      "swiftwater cliffs",
      "tcri building",
      "thornwood falls",
      "tranquil cove",
      "vulcan",
      "wind-scarred crag",
    ]
  end

  def to_s
    "is:gainland"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a gainland"
  end
end

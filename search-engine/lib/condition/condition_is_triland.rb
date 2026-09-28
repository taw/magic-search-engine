class ConditionIsTriland < ConditionNickname
  def names
    [
      "arcane sanctum",
      "crumbling necropolis",
      "frontier bivouac",
      "jungle shrine",
      "mystic monastery",
      "nomad outpost",
      "opulent palace",
      "sandsteppe citadel",
      "savage lands",
      "seaside citadel",
    ]
  end

  def to_s
    "is:triland"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a tri-colored land that enters the battlefield tapped"
  end
end

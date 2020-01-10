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
end

class ConditionIsShadowland < ConditionNickname
  def names
    [
      "choked estuary",
      "foreboding ruins",
      "fortified village",
      "frostboil snarl",
      "furycalm snarl",
      "game trail",
      "necroblossom snarl",
      "port town",
      "shineshadow snarl",
      "vineglimmer snarl",
    ]
  end

  def to_s
    "is:shadowland"
  end

  def explain
    "the card is a shadowland"
  end
end

class ConditionIsSlowland < ConditionNickname
  def names
    [
      "deathcap glade",
      "deserted beach",
      "dreamroot cascade",
      "haunted ridge",
      "overgrown farmland",
      "rockfall vale",
      "shattered sanctum",
      "shipwreck marsh",
      "stormcarved coast",
      "sundown pass",
    ]
  end

  def to_s
    "is:slowland"
  end

  def explain
    "the card is a slowland"
  end
end

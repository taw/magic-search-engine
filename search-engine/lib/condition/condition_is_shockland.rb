class ConditionIsShockland < ConditionNickname
  def names
    [
      "blood crypt",
      "breeding pool",
      "godless shrine",
      "hallowed fountain",
      "overgrown tomb",
      "sacred foundry",
      "steam vents",
      "stomping ground",
      "temple garden",
      "watery grave",
    ]
  end

  def to_s
    "is:shockland"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a shockland"
  end
end

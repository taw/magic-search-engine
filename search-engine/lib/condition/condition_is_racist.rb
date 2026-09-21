class ConditionIsRacist < ConditionNickname
  def names
    [
      "cleanse",
      "crusade",
      "imprison",
      "invoke prejudice",
      "jihad",
      "pradesh gypsies",
      "stone-throwing devils",
    ]
  end

  def to_s
    "is:racist"
  end

  def explain
    "the card is on Wizards' list of cards with racist names or imagery"
  end
end

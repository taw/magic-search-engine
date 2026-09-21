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

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}on Wizards' list of cards with racist names or imagery"
  end
end

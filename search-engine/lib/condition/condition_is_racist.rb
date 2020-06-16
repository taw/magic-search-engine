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
end

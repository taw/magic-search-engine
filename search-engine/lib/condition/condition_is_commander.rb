class ConditionIsCommander < ConditionSimple
  def match?(card)
    card.commander?
  end

  def to_s
    "is:commander"
  end

  def explain
    "the card is playable as a Commander"
  end
end

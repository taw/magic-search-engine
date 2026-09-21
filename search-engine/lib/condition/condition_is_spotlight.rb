class ConditionIsSpotlight < ConditionSimple
  def match?(card)
    card.spotlight
  end

  def to_s
    "is:spotlight"
  end

  def explain
    "the card is a Story Spotlight"
  end
end

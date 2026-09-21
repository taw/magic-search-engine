class ConditionIsSpotlight < ConditionSimple
  def match?(card)
    card.spotlight
  end

  def to_s
    "is:spotlight"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a Story Spotlight"
  end
end

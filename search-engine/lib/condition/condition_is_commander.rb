class ConditionIsCommander < ConditionSimple
  def match?(card)
    card.commander?
  end

  def to_s
    "is:commander"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}playable as a Commander"
  end
end

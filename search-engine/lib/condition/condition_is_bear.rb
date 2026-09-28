class ConditionIsBear < ConditionSimple
  # No type check, so the few 2/2 Vehicles and Spacecraft for {2} are bears as well
  def match?(card)
    card.power == 2 and card.toughness == 2 and card.mv == 2
  end

  def to_s
    "is:bear"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a 2/2 for two mana (a \"bear\")"
  end
end

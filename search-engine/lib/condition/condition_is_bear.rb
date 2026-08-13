class ConditionIsBear < ConditionSimple
  # No type check, so the few 2/2 Vehicles and Spacecraft for {2} are bears as well
  def match?(card)
    card.power == 2 and card.toughness == 2 and card.mv == 2
  end

  def to_s
    "is:bear"
  end
end

class ConditionIsGamechanger < ConditionSimple
  def match?(card)
    card.game_changer
  end

  def to_s
    "is:gamechanger"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}on the Commander Game Changer list"
  end
end

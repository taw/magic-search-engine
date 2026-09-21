class ConditionIsGamechanger < ConditionSimple
  def match?(card)
    card.game_changer
  end

  def to_s
    "is:gamechanger"
  end

  def explain
    "the card is on the Commander Game Changer list"
  end
end

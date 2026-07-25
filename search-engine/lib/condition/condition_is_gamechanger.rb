class ConditionIsGamechanger < ConditionSimple
  def match?(card)
    card.game_changer
  end

  def to_s
    "is:gamechanger"
  end
end

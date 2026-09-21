class ConditionIsPregame < ConditionNickname
  def names
    [
      # chancellor cycle - reveal from opening hand for a delayed pregame effect
      "chancellor of the annex",
      "chancellor of the dross",
      "chancellor of the forge",
      "chancellor of the mulligan",
      "chancellor of the spires",
      "chancellor of the tangle",
      "devourer of destiny",
      "providence",
      "sphinx of foresight",
      # if this card is in your opening hand, you may begin the game with it on the battlefield
      "gemstone caverns",
      "leyline axe",
      "leyline of abundance",
      "leyline of anticipation",
      "leyline of combustion",
      "leyline of hope",
      "leyline of lifeforce",
      "leyline of lightning",
      "leyline of mutation",
      "leyline of punishment",
      "leyline of resonance",
      "leyline of sanctity",
      "leyline of singularity",
      "leyline of the guildpact",
      "leyline of the meek",
      "leyline of the void",
      "leyline of transformation",
      "leyline of vitality",
      "quicksilver, brash blur",
      "welcome to australia",
      # if this card is in your opening hand, you may do something else with it
      "impatient iguana",
      "time sidewalk",
      # any time you could mulligan and this card is in your hand
      "no-regrets egret",
      "serum powder"
    ]
  end

  def to_s
    "is:pregame"
  end

  def explain
    "the card does something special just from being in your opening hand"
  end
end

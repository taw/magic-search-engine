class ConditionIsPermanent < ConditionSimple
  # There are some weird unset and special set cards.
  # These are definitely permanents:
  # * UNH Atinlay Igpay (Eaturecray - Igpay)
  #   definitely a creature, spelling is just a joke
  # * PH21 Byode, Inverse Sun (Legendary Universewalker - Byode)
  #   definitely a planeswalker, spelling is just a joke
  # * PHTR Dungeon Master (Legendary Planeswalker - Dungeon Master)
  #   definitely a creature, just Dungeon is normally a non-permanent type
  # * CMB1/2 "Instant Creature - *" cards
  #   definitely creatures, the joke is using Instant as supertype
  # * UNK Blue Screen of Death (Legendary Instant Artifact Enchantment)
  #   definitely permanent, the joke is using Instant as supertype
  # * some old uncards/promos with "Summon" instead of "Creature" like UNH Old Fogey
  #   definitely creatures, they just use old wording intentionally
  #
  # There's also borderline case, which could be treated as emblem instead:
  # * THP1 cards with "Hero" as the only type

  PERMANENT_TYPES = %w[
    artifact battle creature enchantment land planeswalker hero
    summon eaturecray universewalker
  ].to_set

  def match?(card)
    card.types.any?{|t| PERMANENT_TYPES.include?(t) }
  end

  def to_s
    "is:permanent"
  end
end

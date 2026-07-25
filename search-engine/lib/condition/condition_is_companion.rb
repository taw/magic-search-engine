class ConditionIsCompanion < ConditionNickname
  # The 10 Ikoria ones have the companion frame effect, the other 3 are funny cards which don't
  # The Companion of the Wilds spells its keyword "Old Companion —"
  def names
    [
      "gyruda, doom of depths",
      "jegantha, the wellspring",
      "kaheera, the orphanguard",
      "keruga, the macrosage",
      "lurrus of the dream-den",
      "lutri, pauper otter",
      "lutri, the spellchaser",
      "obosh, the preypiercer",
      "the companion of the wilds",
      "treizeci, sun of serra",
      "umori, the collector",
      "yorion, sky nomad",
      "zirda, the dawnwaker",
    ]
  end

  def to_s
    "is:companion"
  end
end

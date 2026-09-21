# Cards playable only in one of Magic's special formats - planes and phenomena
# (Planechase), schemes (Archenemy), vanguards, conspiracies, and the Theros
# Hero's Path and challenge decks. They are legal in no ordinary format at any
# date, which is what formats use this for.
class ConditionIsSpecialformat < ConditionSimple
  def match?(card)
    card.special_format
  end

  def to_s
    "is:specialformat"
  end

  def explain
    "the card is playable only in a special format (Planechase, Archenemy, vanguard, conspiracy, or a Theros Hero's Path/challenge deck)"
  end
end

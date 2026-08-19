# Cards playable only in one of Magic's special formats - planes and phenomena
# (Planechase), schemes (Archenemy), vanguards, conspiracies, and the Theros
# Hero's Path and challenge decks. They are legal in no ordinary format at any
# date, which is what formats use this for.
#
# Alchemy cards are not here - they're ordinary cards legal on Arena, see is:alchemy.
class ConditionIsSpecialformat < ConditionSimple
  def match?(card)
    card.special_format
  end

  def to_s
    "is:specialformat"
  end
end

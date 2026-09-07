# The holofoil sticker in the bottom center of the card. mtgjson records its shape,
# and the shape answers nearly everything: the oval (Magic 2015 onwards, gold on
# Amonkhet Invocations), the Signature Spellbook circle and the Ponies heart are
# always holofoil, and they show up on commons, uncommons and basics too whenever the
# printing is a promo or a Booster Fun treatment.
#
# The Universes Beyond triangle and the Unfinity acorn are holofoil only on rares and
# mythics; lower rarities get a flat silver triangle or an acorn printed on the card
# instead of embossed on it.
#
# Digital printings are out even when mtgjson gives them a stamp: MTGO just draws the
# paper card's sticker, and the Arena "A" is a rendered badge rather than foil. Back
# faces are out because the sticker is on the front.
class ConditionIsHolofoil < ConditionSimple
  RARE = IndexFormat::RARITIES.index("rare")

  def match?(card)
    return false unless card.paper?
    return false if card.back?
    case card.stamp
    when "oval", "circle", "heart"
      true
    when "triangle", "acorn"
      card.rarity_code >= RARE
    else
      false
    end
  end

  def to_s
    "is:holofoil"
  end
end

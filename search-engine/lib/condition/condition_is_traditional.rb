# A traditional Magic card - normal size, normal thickness, normal back, normal
# border. not:traditional is oversized and thick display cards, gold-bordered
# World Championship decks, and the Collectors' Edition / 30th Anniversary
# reprints. It is about the physical object, not about what the card does: un-cards,
# acorn cards and playtest cards are all traditional cards by this test.
class ConditionIsTraditional < ConditionSimple
  def match?(card)
    !card.nontraditional
  end

  def to_s
    "is:traditional"
  end
end

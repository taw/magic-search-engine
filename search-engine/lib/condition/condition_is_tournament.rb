# Printings you can bring to a sanctioned event. This is what format legality is
# built on, and it is printing-level on purpose - Counterspell is legal while its
# playtest-framed sld/sctlr printing is not, and MB2's ordinary reprints are legal
# while its playtest cards in the same set are not.
#
# not:tournament is not:traditional (oversized, gold-bordered, Collectors' Edition)
# plus CR 100.7's cards intended for casual play (playtest cards, silver borders,
# acorn stamps, and the un-sets and oddball products the CR's list does not exhaust).
class ConditionIsTournament < ConditionSimple
  def match?(card)
    !card.nontournament
  end

  def to_s
    "is:tournament"
  end
end

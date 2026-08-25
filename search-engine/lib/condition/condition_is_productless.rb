# Printings we know no way to get: no preconstructed deck, no booster, and no
# product naming them in its own contents. Mostly gaps in our product data, so
# cards move out of here as it gets filled in, but some printings are genuinely
# in nothing - a judge gift promo was handed out on its own and there is no
# product for it to be in.
class ConditionIsProductless < Condition
  # Which finish the query asks about, or nil for "any of them". The
  # per-finish subclasses are undocumented debug queries - see
  # CardDatabase#productless_printings for what they mean.
  def finish
    nil
  end

  def search(db, candidates=db.printings)
    db.productless_printings(candidates, finish: finish)
  end

  # The scan itself costs the same either way, but there is one fewer printing
  # to ask about for every one something else already ruled out
  def uses_candidates?
    true
  end

  def to_s
    "is:productless#{finish}"
  end
end

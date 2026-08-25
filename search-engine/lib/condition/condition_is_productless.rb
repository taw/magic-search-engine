# Printings we know no way to get: no preconstructed deck, no booster, and no
# product naming them in its own contents. Mostly gaps in our product data, so
# cards move out of here as it gets filled in, but some printings are genuinely
# in nothing - a judge gift promo was handed out on its own and there is no
# product for it to be in.
class ConditionIsProductless < Condition
  def search(db, candidates=db.printings)
    db.productless_printings(candidates)
  end

  # The scan itself costs the same either way, but there is one fewer printing
  # to ask about for every one something else already ruled out
  def uses_candidates?
    true
  end

  def to_s
    "is:productless"
  end
end

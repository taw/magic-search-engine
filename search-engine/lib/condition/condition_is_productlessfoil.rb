# Printed in foil, but nothing we know of has it in foil, whatever
# the other finishes do. Debug query for holes in the product data - see
# ConditionIsProductless.
class ConditionIsProductlessfoil < ConditionIsProductless
  def finish
    :foil
  end

  def explain(negated: false)
    negated ? "the card has a known product source (booster, precon, or promo) in foil finish" : "the card has no known product source (booster, precon, or promo) in foil finish"
  end
end

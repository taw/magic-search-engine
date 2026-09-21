# Printed in etched, but nothing we know of has it in etched, whatever
# the other finishes do. Debug query for holes in the product data - see
# ConditionIsProductless.
class ConditionIsProductlessetched < ConditionIsProductless
  def finish
    :etched
  end

  def explain(negated: false)
    negated ? "the card has a known product source (booster, precon, or promo) in etched finish" : "the card has no known product source (booster, precon, or promo) in etched finish"
  end
end

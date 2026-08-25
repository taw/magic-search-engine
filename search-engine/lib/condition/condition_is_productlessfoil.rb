# Printed in foil, but nothing we know of has it in foil, whatever
# the other finishes do. Debug query for holes in the product data - see
# ConditionIsProductless.
class ConditionIsProductlessfoil < ConditionIsProductless
  def finish
    :foil
  end
end

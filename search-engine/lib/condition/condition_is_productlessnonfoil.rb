# Printed in nonfoil, but nothing we know of has it in nonfoil, whatever
# the other finishes do. Debug query for holes in the product data - see
# ConditionIsProductless.
class ConditionIsProductlessnonfoil < ConditionIsProductless
  def finish
    :nonfoil
  end
end

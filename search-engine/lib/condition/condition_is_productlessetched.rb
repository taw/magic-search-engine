# Printed in etched, but nothing we know of has it in etched, whatever
# the other finishes do. Debug query for holes in the product data - see
# ConditionIsProductless.
class ConditionIsProductlessetched < ConditionIsProductless
  def finish
    :etched
  end
end

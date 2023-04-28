require "timeout"

# This needs timeout check, as it can be exponentially slow
class ConditionRegexp < ConditionSimple
  def initialize(regexp)
    @regexp = regexp
  end

  def match?(card)
    raise "SubclassResponsibility"
  end
end

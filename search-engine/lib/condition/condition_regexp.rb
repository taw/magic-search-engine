require "timeout"

# This would be ConditionSimple, except user-provided regular expressions
# can very easily be exponentially slow
class ConditionRegexp < Condition
  def initialize(regexp)
    @regexp = regexp
  end

  def search(db)
    Timeout.timeout(30) do
      db.printings.select{|card| match?(card)}.to_set
    end
  end

  def match?(card)
    raise "SubclassResponsibility"
  end
end

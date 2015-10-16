# Conditions for which you don't need to run #search, #match? is enough
class ConditionSimple < Condition
  def search(db)
    # Set#select should return damn set, it's dumb that it returns Array
    Set.new(db.printings.select{|card| match?(card)})
  end

  def match?(card)
    raise "SubclassResponsibility"
  end

  def simple?
    true
  end
end

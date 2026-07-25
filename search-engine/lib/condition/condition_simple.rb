# Conditions for which you don't need to run #search, #match? is enough
class ConditionSimple < Condition
  def search(db, candidates=db.printings)
    # Set#select should return damn set, it's dumb that it returns Array.
    # It also goes through Enumerable, so #to_a first - Array#select is a lot faster.
    candidates.to_a.select{|card| match?(card)}.to_set
  end

  def match?(card)
    raise "SubclassResponsibility"
  end

  def uses_candidates?
    true
  end

  def simple?
    true
  end
end

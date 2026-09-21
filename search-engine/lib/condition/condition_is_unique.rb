class ConditionIsUnique < ConditionSimple
  def match?(card)
    card.printings.size == 1
  end

  def to_s
    "is:unique"
  end

  def explain
    "the card has never been reprinted"
  end
end

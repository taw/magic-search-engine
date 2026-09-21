class ConditionIsBaseset < ConditionSimple
  def match?(card)
    card.baseset?
  end

  def to_s
    "is:baseset"
  end

  def explain
    "the card's number falls within the base set's numbering range, and it is not foreign, misprint, or Arena variant"
  end
end

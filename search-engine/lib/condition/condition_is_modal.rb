class ConditionIsModal < ConditionSimple
  def match?(card)
    card.modal
  end

  def to_s
    "is:modal"
  end
end

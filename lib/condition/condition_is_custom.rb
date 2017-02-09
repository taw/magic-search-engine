class ConditionIsCustom < ConditionSimple
  def match?(card)
    return true if card.printings.all? { |printing| printing.set.custom? }
    false
  end

  def to_s
    "is:custom"
  end
end

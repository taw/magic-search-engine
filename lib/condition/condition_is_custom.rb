class ConditionIsCustom < ConditionSimple
  def match?(printing)
    printing.card.custom?
  end

  def to_s
    "is:custom"
  end
end

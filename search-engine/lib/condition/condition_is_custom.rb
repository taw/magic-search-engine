class ConditionIsCustom < ConditionSimple
  def match?(printing)
    printing.card.custom?
  end

  def to_s
    "is:custom"
  end

  def explain(negated: false)
    negated ? "the card is not custom-made (it has an official printing)" : "the card is a custom, fan-made card with no official printing"
  end
end

class ConditionIsCustom < ConditionSimple
  def match?(printing)
    printing.card.custom?
  end

  def to_s
    "is:custom"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a custom card"
  end
end

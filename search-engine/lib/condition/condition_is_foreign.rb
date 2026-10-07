class ConditionIsForeign < ConditionSimple
  def match?(card)
    card.language
  end

  def to_s
    "is:foreign"
  end

  def explain(negated: false)
    negated ? "the card has an English printing" : "the card is only printed in foreign languages"
  end
end

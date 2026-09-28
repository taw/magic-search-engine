class ConditionIsHero < ConditionSimple
  def match?(card)
    card.watermark == "herospath" and card.types.include?("hero")
  end

  def to_s
    "is:hero"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a Hero's Path card"
  end
end

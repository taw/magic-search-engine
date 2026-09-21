class ConditionIsVanilla < ConditionSimple
  BASIC_LAND_TYPES = %W[plains mountain forest swamp island].freeze

  def match?(card)
    card.text.empty? and (card.types & BASIC_LAND_TYPES).empty?
  end

  def to_s
    "is:vanilla"
  end

  def explain(negated: false)
    negated ? "the card has rules text or is a basic land" : "the card has no rules text and is not a basic land"
  end
end

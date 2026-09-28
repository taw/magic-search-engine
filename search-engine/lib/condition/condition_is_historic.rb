class ConditionIsHistoric < ConditionSimple
  def match?(card)
    card_types = card.types
    ["legendary", "artifact", "saga"].any? do |type|
      card_types.include?(type)
    end
  end

  def to_s
    "is:historic"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}historic (legendary, artifact, or Saga)"
  end
end

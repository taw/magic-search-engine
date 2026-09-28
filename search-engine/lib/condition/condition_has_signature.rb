class ConditionHasSignature < ConditionSimple
  def match?(card)
    !!card.signature
  end

  def to_s
    "has:signature"
  end

  def explain(negated: false)
    negated ? "the card has no signature" : "the card has a signature"
  end
end

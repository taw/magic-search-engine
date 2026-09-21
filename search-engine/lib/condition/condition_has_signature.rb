class ConditionHasSignature < ConditionSimple
  def match?(card)
    !!card.signature
  end

  def to_s
    "has:signature"
  end

  def explain
    "the card has a signature"
  end
end

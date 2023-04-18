class ConditionHasSignature < ConditionSimple
  def match?(card)
    !!card.signature
  end

  def to_s
    "has:signature"
  end
end

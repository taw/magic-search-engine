class ConditionIsMultipart < ConditionSimple
  def match?(card)
    card.has_multiple_parts?
  end

  def to_s
    "is:multipart"
  end

  def explain(negated: false)
    negated ? "the card has a single part, not split, flip, or double-faced" : "the card has multiple parts (split, flip, or double-faced)"
  end
end

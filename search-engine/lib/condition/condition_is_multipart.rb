class ConditionIsMultipart < ConditionSimple
  def match?(card)
    card.has_multiple_parts?
  end

  def to_s
    "is:multipart"
  end

  def explain
    "the card has multiple parts (split, flip, or double-faced)"
  end
end

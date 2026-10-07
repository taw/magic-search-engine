class ConditionIsMultipart < ConditionSimple
  def match?(card)
    card.has_multiple_parts?
  end

  def to_s
    "is:multipart"
  end

  def explain(negated: false)
    negated ? "the card has a single part" : "the card has multiple parts"
  end
end

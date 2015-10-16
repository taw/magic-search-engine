class ConditionIsMultipart < ConditionSimple
  def match?(card)
    card.has_multiple_parts?
  end

  def to_s
    "is:multipart"
  end
end

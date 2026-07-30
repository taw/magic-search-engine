class ConditionFullOracle < ConditionOracle
  def to_s
    "fo:#{maybe_quote(@text)}"
  end

  private

  # Reminder text refers to the card the same ways rules text does - by full name, by
  # short name ("whenever B.O.B. gains or loses loyalty"), or without naming it at all -
  # so ~ means exactly what it means under o:, and only the text searched differs
  def oracle_text(card)
    card.fulltext_normalized
  end
end

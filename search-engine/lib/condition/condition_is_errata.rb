class ConditionIsErrata < ConditionSimple
  def match?(printing)
    return true if printing.printed_name != printing.card.name
    return true if printing.printed_typeline != printing.card.typeline
    return true if printing.printed_text != printing.card.text
    false
  end

  def to_s
    "is:errata"
  end
end

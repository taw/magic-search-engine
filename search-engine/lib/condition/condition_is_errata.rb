class ConditionIsErrata < ConditionSimple
  def match?(printing)
    printing.printed_text != printing.card.text
  end

  def to_s
    "is:errata"
  end
end

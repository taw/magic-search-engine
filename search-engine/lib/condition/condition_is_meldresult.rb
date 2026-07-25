class ConditionIsMeldresult < ConditionSimple
  # Meld parts have one other part, meld results have two
  def match?(card)
    card.layout == "meld" and (card.others || []).size == 2
  end

  def to_s
    "is:meldresult"
  end
end

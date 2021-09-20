class ConditionIsDfc < ConditionSimple
  def match?(card)
    layout = card.layout
    layout == "transform" or layout == "meld" or layout == "modaldfc"
  end

  def to_s
    "is:dfc"
  end
end

class ConditionIsSfc < ConditionSimple
  def match?(card)
    layout = card.layout
    layout != "transform" and layout != "meld" and layout != "modaldfc"
  end

  def to_s
    "is:sfc"
  end
end

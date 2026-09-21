class ConditionIsVergeland < ConditionNickname
  def names
    [
      "blazemire verge",
      "bleachbone verge",
      "floodfarm verge",
      "gloomlake verge",
      "hushwood verge",
      "riverpyre verge",
      "sunbillow verge",
      "thornspire verge",
      "wastewood verge",
      "willowrush verge",
    ]
  end

  def to_s
    "is:vergeland"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a verge land"
  end
end

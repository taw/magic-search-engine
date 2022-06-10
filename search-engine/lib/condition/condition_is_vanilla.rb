class ConditionIsVanilla < ConditionSimple
  def match?(card)
    card.text == "" and (card.types & ["plains", "mountain", "forest", "swamp", "island"]).empty?
  end

  def to_s
    "is:vanilla"
  end
end

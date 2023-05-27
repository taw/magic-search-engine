class ConditionIsMaindeck < ConditionSimple
  def match?(card)
    return false if card.watermark == "herospath" and card.types.include?("hero")
    return false if card.layout == "dungeon"
    (card.types & %w[attraction conspiracy contraption phenomenon plane scheme stickers vanguard]).empty?
  end

  def to_s
    "is:maindeck"
  end
end

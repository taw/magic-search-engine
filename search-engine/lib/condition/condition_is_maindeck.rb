class ConditionIsMaindeck < ConditionSimple
  NOT_IN_MAINDECK = %W[attraction conspiracy contraption phenome-nom phenomenon plane scheme stickers vanguard].freeze

  def match?(card)
    return false if card.watermark == "herospath" and card.types.include?("hero")
    return false if card.layout == "dungeon"
    (card.types & NOT_IN_MAINDECK).empty?
  end

  def to_s
    "is:maindeck"
  end
end

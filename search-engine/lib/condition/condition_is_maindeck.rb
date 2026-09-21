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

  def explain(negated: false)
    negated ? "the card is not a type that could go into a main deck (Attraction, Conspiracy, Contraption, Dungeon, Hero's Path, Phenomenon, Plane, Scheme, Stickers, or Vanguard)" : "the card is a type that could go into a main deck (not Attraction, Conspiracy, Contraption, Dungeon, Hero's Path, Phenomenon, Plane, Scheme, Stickers, or Vanguard)"
  end
end

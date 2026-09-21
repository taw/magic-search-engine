class ConditionIsBrawler < ConditionSimple
  def match?(card)
    card.brawler?
  end

  def to_s
    "is:brawler"
  end

  def explain
    "the card is playable as a Brawl commander (a legendary creature or planeswalker)"
  end
end

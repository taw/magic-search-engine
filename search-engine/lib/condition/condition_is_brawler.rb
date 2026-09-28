class ConditionIsBrawler < ConditionSimple
  def match?(card)
    card.brawler?
  end

  def to_s
    "is:brawler"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}playable as a Brawl commander (a legendary creature or planeswalker)"
  end
end

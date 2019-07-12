class ConditionIsBrawler < ConditionSimple
  def match?(card)
    card.brawler?
  end

  def to_s
    "is:brawler"
  end
end

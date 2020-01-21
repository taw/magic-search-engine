class ConditionIsBuyabox < ConditionSimple
  def match?(card)
    card.buyabox
  end

  def to_s
    "is:buyabox"
  end
end

class ConditionIsMainfront < ConditionSimple
  def match?(card)
    card.main_front == card
  end

  def to_s
    "is:mainfront"
  end
end

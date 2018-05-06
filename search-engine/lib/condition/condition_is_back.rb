class ConditionIsBack < ConditionSimple
  def match?(card)
    card.back?
  end

  def to_s
    "is:back"
  end
end

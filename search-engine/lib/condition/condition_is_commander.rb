class ConditionIsCommander < ConditionSimple
  def match?(card)
    card.commander?
  end

  def to_s
    "is:commander"
  end
end

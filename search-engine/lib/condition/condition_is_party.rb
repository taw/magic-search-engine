class ConditionIsParty < ConditionSimple
  TYPES = ["cleric", "rogue", "warrior", "wizard"]

  # Party members are creatures only, changelings are every creature type
  def match?(card)
    return false unless card.types.include?("creature")
    return true if card.keywords&.include?("changeling")
    !(card.types & TYPES).empty?
  end

  def to_s
    "is:party"
  end
end

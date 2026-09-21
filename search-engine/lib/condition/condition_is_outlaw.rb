class ConditionIsOutlaw < ConditionSimple
  TYPES = ["assassin", "mercenary", "pirate", "rogue", "warlock"]

  # Any card with one of these creature types is an outlaw, not just creatures,
  # so Kindred cards count, and so do changelings
  def match?(card)
    return true if card.keywords&.include?("changeling")
    !(card.types & TYPES).empty?
  end

  def to_s
    "is:outlaw"
  end

  def explain
    "the card is an outlaw (Assassin, Mercenary, Pirate, Rogue, Warlock, or a changeling)"
  end
end

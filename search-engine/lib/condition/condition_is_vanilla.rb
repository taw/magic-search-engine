class ConditionIsVanilla < ConditionSimple
  BASIC_LAND_TYPES = %W[plains mountain forest swamp island].freeze

  def match?(card)
    card.text.empty? and (card.types & BASIC_LAND_TYPES).empty?
  end

  def to_s
    "is:vanilla"
  end
end

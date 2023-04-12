class ConditionIsBasictype < ConditionSimple
  def match?(card)
    !(card.types & %w[plains island swamp mountain forest]).empty?
  end

  def to_s
    "is:basictype"
  end
end

class ConditionIsReprint < ConditionSimple
  def match?(card)
    card.release_date != card.first_release_date
  end

  def to_s
    "is:reprint"
  end
end

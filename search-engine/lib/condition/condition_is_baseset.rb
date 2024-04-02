class ConditionIsBaseset < ConditionSimple
  def match?(card)
    return false if card.variant_foreign or card.variant_misprint or card.promo_types&.include?("reversibleback")
    base_set_size = card.set.base_set_size
    return false unless base_set_size
    number_i = card.number_i
    number_i >= 1 and number_i <= base_set_size
  end

  def to_s
    "is:baseset"
  end
end

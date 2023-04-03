class ConditionPromoType < ConditionSimple
  def initialize(promo_type)
    @promo_type = promo_type.downcase
  end

  def match?(card)
    card.promo_types&.include?(@promo_type)
  end

  def to_s
    "promo:#{@promo_type}"
  end
end

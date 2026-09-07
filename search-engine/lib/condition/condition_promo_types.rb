class ConditionPromoType < ConditionSimple
  def initialize(promo_type)
    @promo_type = promo_type.downcase
    @any = (@promo_type == "*")
  end

  def match?(card)
    if @any
      card.promo_types and !card.promo_types.empty?
    else
      card.promo_types&.include?(@promo_type)
    end
  end

  def to_s
    "promo:#{@promo_type}"
  end
end

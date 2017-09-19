class ConditionRarity < ConditionSimple
  def initialize(op, rarity)
    @op = op
    @rarity = rarity.downcase
    @rarity = "basic" if @rarity == "b"
    @rarity = "basic" if @rarity == "l"
    @rarity = "common" if @rarity == "c"
    @rarity = "uncommon" if @rarity == "u"
    @rarity = "rare" if @rarity == "r"
    @rarity = "mythic" if @rarity == "m"
    @rarity = "special" if @rarity == "s"
    @rarity_code = %W[basic common uncommon rare mythic special].index(@rarity) or raise "Unknown rarity #{@rarity}"
  end

  def match?(card)
    case @op
    when "="
      card.rarity_code == @rarity_code
    when ">"
      card.rarity_code > @rarity_code
    when ">="
      card.rarity_code >= @rarity_code
    when "<="
      card.rarity_code <= @rarity_code
    when "<"
      card.rarity_code < @rarity_code
    else
      raise "Unrecognized comparison #{@op}"
    end
  end

  def to_s
    "r#{@op}#{@rarity}"
  end
end

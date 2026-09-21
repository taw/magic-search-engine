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
    @rarity = "special" if @rarity == "bonus"
    @rarity = "mythic" if @rarity == "mythic rare"
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

  OP_WORDS = {"=" => "is", ">=" => "is at least", "<=" => "is at most", ">" => "is rarer than", "<" => "is more common than"}
  NEGATED_OP_WORDS = {"=" => "isn't", ">=" => "is more common than", "<=" => "is rarer than", ">" => "is at most", "<" => "is at least"}

  def explain(negated: false)
    words = negated ? NEGATED_OP_WORDS : OP_WORDS
    "the rarity #{words.fetch(@op, @op)} #{@rarity}"
  end
end

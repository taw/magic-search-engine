class ConditionProduces < ConditionSimple
  def initialize(op, mana)
    @op = op
    @mana = mana.downcase.chars.grep(/[wubrgc]/).to_set
  end

  def match?(card)
    card_produces = card.produces&.chars&.to_set || Set[]

    case @op
    when ">="
      card_produces >= @mana
    when ">"
      card_produces > @mana
    when "="
      card_produces == @mana
    when "!="
      card_produces != @mana
    when "<"
      card_produces < @mana
    when "<="
      card_produces <= @mana
    else
      raise "Unrecognized comparison #{@op}"
    end
  end

  def to_s
    "produces#{@op}#{@mana.join}"
  end
end

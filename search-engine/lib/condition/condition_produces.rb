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

  # Produced mana is a set of colors, so it's worded the same as c>=
  def explain(negated: false)
    return "the card #{(@op == "=") ^ negated ? "doesn't produce" : "produces"} mana" if @mana.empty? and %w[= !=].include?(@op)
    words = negated ? ConditionColorExpr::NEGATED_OP_WORDS : ConditionColorExpr::OP_WORDS
    symbols = "wubrgc".chars.select{|c| @mana.include?(c)}.map{|c| "{#{c}}"}.join
    "the mana produced #{words.fetch(@op)} #{symbols}"
  end
end

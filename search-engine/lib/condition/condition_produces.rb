class ConditionProduces < ConditionSimple
  def initialize(op, mana)
    @op = op
    @mana = mana
  end

  def match?(card)
    true
  end

  def to_s
    "produces#{@op}#{@mana}"
  end
end

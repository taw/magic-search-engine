class ConditionColorExpr < ConditionSimple
  def initialize(a, op, b)
    @a = a.downcase
    @op = op
    @b = b.downcase
    @bset = Color.matching(@op, @b)
  end

  def match?(card)
    if @a == "c"
      a = card.colors
    elsif @a == "ind"
      a = card.color_indicator_colors
      return false unless a
    else
      a = card.color_identity
    end

    @bset.include?(a)
  end

  # c:c instead of c:""
  def to_s
    b = @b
    b = "c" if b == ""
    "#{@a}#{@op}#{maybe_quote(b)}"
  end
end

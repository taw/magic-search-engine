class ConditionColorExpr < ConditionSimple
  def initialize(a, op, b)
    @a = a.downcase
    @op = op
    @b = b.downcase
    @bset = Color.matching(@op, @b)
    @colors = (@a == "c")
    @indicator = (@a == "ind")
  end

  def match?(card)
    if @colors
      a = card.colors
    elsif @indicator
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

  FIELD_NAMES = {"c" => "the colors", "ci" => "the color identity", "ind" => "the color indicator"}
  OP_WORDS = {"=" => "is", "!=" => "isn't", ">=" => "includes at least", "<=" => "is at most", ">" => "is more than", "<" => "is less than", ":" => "includes"}

  def explain
    "#{FIELD_NAMES.fetch(@a, "the #{@a}")} #{OP_WORDS.fetch(@op, @op)} #{explain_value}"
  end

  private

  def explain_value
    return "colorless" if @b == "" || @b == "c"
    return "#{@b} colors" if @b =~ /\A\d+\z/
    return @b.chars.sort_by{|c| "wubrg".index(c)}.join.upcase if @b =~ /\A[wubrg]+\z/
    @b
  end
end
